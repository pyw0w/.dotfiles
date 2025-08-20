from typing import Any, Callable, Dict, List, Optional

import dbus
from dbus.mainloop.glib import DBusGMainLoop
import dbusmock

from gi.repository import GLib


class _EventMixin:
    def __init__(self):
        self._event_handlers: Dict[str, List[Callable[..., Any]]] = {}

    def connect(self, event_name: str, handler: Callable[..., Any]):
        self._event_handlers.setdefault(event_name, []).append(handler)

    def emit(self, event_name: str, *args):
        for handler in self._event_handlers.get(event_name, []):
            try:
                handler(*args)
            except Exception:
                pass

    def notify(self, prop_name: str):
        self.emit(f"notify::{prop_name}")


# Ensure dbus-python integrates with GLib main loop used by Fabric
DBusGMainLoop(set_as_default=True)


# dbus-python returns special types; convert to native Python

def _dbus_to_py(value: Any) -> Any:
    if isinstance(value, dbus.Signature) or isinstance(value, dbus.ObjectPath):
        return str(value)
    if isinstance(value, dbus.String):
        return str(value)
    if isinstance(value, (dbus.Boolean,)):
        return bool(value)
    if isinstance(value, (dbus.Int16, dbus.Int32, dbus.Int64, dbus.UInt16, dbus.UInt32, dbus.UInt64)):
        return int(value)
    if isinstance(value, (dbus.Double,)):
        return float(value)
    if isinstance(value, (list, tuple)):
        return [ _dbus_to_py(v) for v in value ]
    if isinstance(value, dict):
        return { _dbus_to_py(k): _dbus_to_py(v) for k, v in value.items() }
    return value


def _get_managed_objects(bus: dbus.SystemBus) -> Dict[str, Dict[str, Dict[str, Any]]]:
    obj = bus.get_object("org.bluez", "/")
    manager = dbus.Interface(obj, "org.freedesktop.DBus.ObjectManager")
    raw = manager.GetManagedObjects()
    return _dbus_to_py(raw)


def _get_properties_iface(bus: dbus.SystemBus, path: str):
    obj = bus.get_object("org.bluez", path)
    return dbus.Interface(obj, "org.freedesktop.DBus.Properties")


def _get_property(bus: dbus.SystemBus, path: str, interface: str, prop: str):
    props = _get_properties_iface(bus, path)
    return _dbus_to_py(props.Get(interface, prop))


def _set_property(bus: dbus.SystemBus, path: str, interface: str, prop: str, value: Any):
    props = _get_properties_iface(bus, path)
    props.Set(interface, prop, value)


def _call_method(bus: dbus.SystemBus, path: str, interface: str, member: str):
    obj = bus.get_object("org.bluez", path)
    iface = dbus.Interface(obj, interface)
    getattr(iface, member)()


class BluetoothDevice(_EventMixin):
    def __init__(self, bus: dbus.SystemBus, path: str, props: Dict[str, Any]):
        super().__init__()
        self._bus = bus
        self._path = path
        self._closed = False
        self._connecting = False

        self._address: str = props.get("Address") or ""
        self._name: str = props.get("Alias") or props.get("Name") or self._address
        self._paired: bool = bool(props.get("Paired", False))
        self._connected: bool = bool(props.get("Connected", False))
        self._icon: str = props.get("Icon") or "bluetooth"

    @property
    def address(self) -> str:
        return self._address

    @property
    def name(self) -> str:
        return self._name

    @property
    def paired(self) -> bool:
        return self._paired

    @property
    def connected(self) -> bool:
        return self._connected

    @property
    def connecting(self) -> bool:
        return self._connecting

    @property
    def icon_name(self) -> str:
        return self._icon

    @property
    def closed(self) -> bool:
        return self._closed

    def set_connecting(self, connect: bool):
        if connect and self._connected:
            return
        if not connect and not self._connected:
            return

        self._connecting = True
        self.emit("changed")
        try:
            if connect:
                _call_method(self._bus, self._path, "org.bluez.Device1", "Connect")
                self._connected = True
            else:
                _call_method(self._bus, self._path, "org.bluez.Device1", "Disconnect")
                self._connected = False
        except Exception:
            pass
        finally:
            self._connecting = False
            self.emit("changed")

    def _update_from_props(self, props: Dict[str, Any]):
        name = props.get("Alias") or props.get("Name")
        if name and name != self._name:
            self._name = name
        paired = bool(props.get("Paired"))
        if paired != self._paired:
            self._paired = paired
        connected = bool(props.get("Connected"))
        if connected != self._connected:
            self._connected = connected
        icon = props.get("Icon")
        if icon and icon != self._icon:
            self._icon = icon
        self.emit("changed")

    def close(self):
        self._closed = True
        self.notify("closed")
        self.emit("changed")


class BluetoothClient(_EventMixin):
    def __init__(self, on_device_added: Optional[Callable[["BluetoothClient", str], Any]] = None, poll_interval_ms: int = 3000):
        super().__init__()
        self._bus = dbus.SystemBus()
        self._adapter_path: Optional[str] = None
        self._devices: Dict[str, BluetoothDevice] = {}
        self._path_to_address: Dict[str, str] = {}
        self.enabled: bool = False
        self.scanning: bool = False
        self._on_device_added = on_device_added

        self._refresh_all(initial=True)

        # BlueZ signal subscriptions for live updates
        self._bus.add_signal_receiver(
            self._on_interfaces_added,
            dbus_interface="org.freedesktop.DBus.ObjectManager",
            signal_name="InterfacesAdded",
        )
        self._bus.add_signal_receiver(
            self._on_interfaces_removed,
            dbus_interface="org.freedesktop.DBus.ObjectManager",
            signal_name="InterfacesRemoved",
        )
        self._bus.add_signal_receiver(
            self._on_properties_changed,
            dbus_interface="org.freedesktop.DBus.Properties",
            signal_name="PropertiesChanged",
            path_keyword="path",
        )

        # Periodic refresh as a fallback in case of missed signals
        GLib.timeout_add(poll_interval_ms, self._on_poll)

    def _on_poll(self):
        try:
            self._refresh_all()
        except Exception:
            pass
        return True

    def _refresh_all(self, initial: bool = False):
        objects = _get_managed_objects(self._bus)
        # adapter
        for path, ifaces in objects.items():
            if "org.bluez.Adapter1" in ifaces:
                self._adapter_path = path
                adapter = ifaces["org.bluez.Adapter1"]
                self.enabled = bool(adapter.get("Powered", False))
                self.scanning = bool(adapter.get("Discovering", False))
                break
        # devices
        for path, ifaces in objects.items():
            dev = ifaces.get("org.bluez.Device1")
            if not dev:
                continue
            address = dev.get("Address")
            if not address:
                continue
            self._path_to_address[path] = address
            existing = self._devices.get(address)
            if existing:
                existing._update_from_props(dev)
            else:
                device = BluetoothDevice(self._bus, path, dev)
                self._devices[address] = device
                if self._on_device_added:
                    try:
                        self._on_device_added(self, address)
                    except Exception:
                        pass
        self.notify("enabled")
        self.notify("scanning")

    def _on_interfaces_added(self, object_path: dbus.ObjectPath, interfaces: dict):
        try:
            interfaces_py = _dbus_to_py(interfaces)
            # Adapter added
            if "org.bluez.Adapter1" in interfaces_py:
                adapter = interfaces_py["org.bluez.Adapter1"]
                self._adapter_path = str(object_path)
                prev_enabled, prev_scanning = self.enabled, self.scanning
                self.enabled = bool(adapter.get("Powered", False))
                self.scanning = bool(adapter.get("Discovering", False))
                if self.enabled != prev_enabled:
                    self.notify("enabled")
                if self.scanning != prev_scanning:
                    self.notify("scanning")
            # Device added
            if "org.bluez.Device1" in interfaces_py:
                dev = interfaces_py["org.bluez.Device1"]
                address = dev.get("Address")
                if not address:
                    return
                self._path_to_address[str(object_path)] = address
                if address in self._devices:
                    self._devices[address]._update_from_props(dev)
                else:
                    device = BluetoothDevice(self._bus, str(object_path), dev)
                    self._devices[address] = device
                    if self._on_device_added:
                        try:
                            self._on_device_added(self, address)
                        except Exception:
                            pass
        except Exception:
            pass

    def _on_interfaces_removed(self, object_path: dbus.ObjectPath, interfaces: list):
        try:
            interfaces_py = _dbus_to_py(interfaces)
            if "org.bluez.Device1" in interfaces_py:
                address = self._path_to_address.pop(str(object_path), None)
                if address and address in self._devices:
                    device = self._devices.pop(address)
                    device.close()
        except Exception:
            pass

    def _on_properties_changed(self, interface: str, changed: dict, invalidated: list, path: Optional[str] = None):
        try:
            changed_py = _dbus_to_py(changed)
            if interface == "org.bluez.Adapter1":
                prev_enabled, prev_scanning = self.enabled, self.scanning
                if "Powered" in changed_py:
                    self.enabled = bool(changed_py["Powered"])
                if "Discovering" in changed_py:
                    self.scanning = bool(changed_py["Discovering"])
                if self.enabled != prev_enabled:
                    self.notify("enabled")
                if self.scanning != prev_scanning:
                    self.notify("scanning")
                return
            if interface == "org.bluez.Device1":
                addr = None
                if path:
                    addr = self._path_to_address.get(path)
                # Try to populate mapping if missing
                if not addr and "Address" in changed_py and path:
                    addr = changed_py["Address"]
                    self._path_to_address[path] = addr
                if addr and addr in self._devices:
                    self._devices[addr]._update_from_props(changed_py)
        except Exception:
            pass

    def get_device(self, address: str) -> Optional[BluetoothDevice]:
        return self._devices.get(address)

    def toggle_power(self):
        if not self._adapter_path:
            return
        new_value = not self.enabled
        try:
            _set_property(self._bus, self._adapter_path, "org.bluez.Adapter1", "Powered", dbus.Boolean(new_value))
            self.enabled = new_value
        except Exception:
            pass
        self.notify("enabled")
        self._refresh_all()

    def toggle_scan(self):
        if not self._adapter_path:
            return
        new_value = not self.scanning
        try:
            if new_value:
                _call_method(self._bus, self._adapter_path, "org.bluez.Adapter1", "StartDiscovery")
            else:
                _call_method(self._bus, self._adapter_path, "org.bluez.Adapter1", "StopDiscovery")
            self.scanning = new_value
        except Exception:
            pass
        self.notify("scanning")
        self._refresh_all() 