import psutil
from fabric import Application, Fabricator
from fabric.widgets.box import Box
from fabric.widgets.image import Image
from fabric.widgets.eventbox import EventBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.centerbox import CenterBox
from fabric.system_tray.widgets import SystemTray
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import (
	HyprlandLanguage,
	HyprlandActiveWindow,
	HyprlandWorkspaces,
	WorkspaceButton,
)
from fabric.utils import FormattedString, get_relative_path, bulk_replace
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.scrolledwindow import ScrolledWindow
import subprocess
from gi.repository import Gdk
import os
import shutil
import glob
import time

AUDIO_WIDGET = True
BLUETOOTH_WIDGET = True

if BLUETOOTH_WIDGET is True:
	try:
		from dbus_py_bluetooth import BluetoothClient, BluetoothDevice
	except Exception as e3:
		BLUETOOTH_WIDGET = False
		print(e3)

if AUDIO_WIDGET is True:
	try:
		from fabric.audio.service import Audio
	except Exception as e:
		AUDIO_WIDGET = False
		print(e)

def truncate_text(text: str, max_len: int) -> str:
	if max_len <= 0:
		return text
	return text if len(text) <= max_len else text[: max_len - 1] + "…"

# Helpers to gather system stats for tooltip

def _read_int(path: str):
	try:
		with open(path, "r") as f:
			return int(f.read().strip())
	except Exception:
		return None


def get_cpu_temperature():
	try:
		temps = psutil.sensors_temperatures(fahrenheit=False)
		values = []
		for _, entries in temps.items():
			for entry in entries:
				cur = getattr(entry, "current", None)
				if cur is not None and cur > 0:
					values.append(cur)
		return max(values) if values else None
	except Exception:
		return None


def get_gpu_stats():
	# Try NVIDIA first
	if shutil.which("nvidia-smi"):
		try:
			out = subprocess.check_output(
				[
					"nvidia-smi",
					"--query-gpu=utilization.gpu,temperature.gpu",
					"--format=csv,noheader,nounits",
				],
				text=True,
				timeout=0.5,
			).strip()
			line = out.splitlines()[0]
			parts = [p.strip() for p in line.split(",")]
			util = int(parts[0]) if parts and parts[0] else None
			temp = float(parts[1]) if len(parts) > 1 and parts[1] else None
			return util, temp
		except Exception:
			pass

	# Generic sysfs (amdgpu/intel)
	try:
		for card in sorted(glob.glob("/sys/class/drm/card[0-9]*")):
			dev = os.path.join(card, "device")
			usage = None
			usage_path = os.path.join(dev, "gpu_busy_percent")
			if os.path.exists(usage_path):
				usage = _read_int(usage_path)
			temp = None
			for tp in glob.glob(os.path.join(dev, "hwmon", "hwmon*", "temp1_input")):
				val = _read_int(tp)
				if val is not None:
					temp = val / 1000.0
					break
			if usage is not None or temp is not None:
				return usage, temp
	except Exception:
			pass

	return None, None

# Track previous network counters for rate calculation
_last_net_sample = {"t": None, "pernic": {}}


def _fmt_rate(bps: float) -> str:
	try:
		units = ["B/s", "KB/s", "MB/s", "GB/s"]
		val = float(bps)
		idx = 0
		while val >= 1024 and idx < len(units) - 1:
			val /= 1024.0
			idx += 1
		return f"{val:.0f}{units[idx]}"
	except Exception:
		return "0B/s"


def get_network_rates():
	global _last_net_sample
	try:
		now = time.monotonic()
		pernic = psutil.net_io_counters(pernic=True)
		if _last_net_sample["t"] is None:
			_last_net_sample = {
				"t": now,
				"pernic": {n: (c.bytes_recv, c.bytes_sent) for n, c in pernic.items()},
			}
			return None, None, None
		elapsed = max(0.001, now - _last_net_sample["t"])
		best_iface = None
		best_down = 0.0
		best_up = 0.0
		stats = psutil.net_if_stats()
		for name, counters in pernic.items():
			if name.startswith("lo"):
				continue
			if name in stats and not stats[name].isup:
				continue
			prev = _last_net_sample["pernic"].get(name)
			if not prev:
				continue
			recv_prev, sent_prev = prev
			down_bps = (counters.bytes_recv - recv_prev) / elapsed
			up_bps = (counters.bytes_sent - sent_prev) / elapsed
			total = down_bps + up_bps
			if total > (best_down + best_up):
				best_iface = name
				best_down = down_bps
				best_up = up_bps
		_last_net_sample = {
			"t": now,
			"pernic": {n: (c.bytes_recv, c.bytes_sent) for n, c in pernic.items()},
		}
		if best_iface is None:
			return None, None, None
		return best_iface, best_down, best_up
	except Exception:
		return None, None, None


def build_status_tooltip() -> str:
	try:
		cpu_usage = int(psutil.cpu_percent())
	except Exception:
		cpu_usage = None
	cpu_temp = get_cpu_temperature()
	gpu_usage, gpu_temp = get_gpu_stats()
	def _fmt_bytes(n: float) -> str:
		try:
			units = ["B", "KB", "MB", "GB", "TB", "PB"]
			idx = 0
			val = float(n)
			while val >= 1024 and idx < len(units) - 1:
				val /= 1024.0
				idx += 1
			return f"{val:.0f}{units[idx]}"
		except Exception:
			return str(int(n))

	lines = []
	line = "CPU: " + (f"{cpu_usage}%" if cpu_usage is not None else "N/A")
	if cpu_temp is not None:
		line += f"  {cpu_temp:.0f}°C"
	lines.append(line)
	try:
		vm = psutil.virtual_memory()
		rline = f"RAM: {int(vm.percent)}%  {_fmt_bytes(vm.used)}/{_fmt_bytes(vm.total)}"
		lines.append(rline)
	except Exception:
		pass
	iface, down_bps, up_bps = get_network_rates()
	if iface is not None and (down_bps is not None and up_bps is not None):
		lines.append(f"NET: {iface}  ↓ {_fmt_rate(down_bps)}  ↑ {_fmt_rate(up_bps)}")

	if gpu_usage is not None or gpu_temp is not None:
		gline = "GPU:"
		if gpu_usage is not None:
			gline += f" {gpu_usage}%"
		if gpu_temp is not None:
			gline += f"  {gpu_temp:.0f}°C"
		lines.append(gline)

	return "\n".join(lines)

class VolumeWidget(Box):
	def __init__(self, **kwargs):
		self.progress_bar = CircularProgressBar(
			name="volume-progress-bar",
			pie=True,
			child=Image(icon_name="audio-speakers-symbolic", icon_size=12),
			size=24,
		)

		self.audio = Audio(notify_speaker=self.on_speaker_changed)

		super().__init__(
			children=EventBox(
				events="scroll", child=self.progress_bar, on_scroll_event=self.on_scroll
			),
			**kwargs,
		)

	def on_scroll(self, _, event):
		match event.direction:
			case 0:
				self.audio.speaker.volume += 8
			case 1:
				self.audio.speaker.volume -= 8
		return

	def on_speaker_changed(self):
		if not self.audio.speaker:
			return

		self.progress_bar.value = self.audio.speaker.volume / 100
		return self.audio.speaker.bind(
			"volume", "value", self.progress_bar, lambda _, v: v / 100
		)


class BluetoothDeviceSlot(CenterBox):
	def __init__(self, device, icon_size: int = 22, max_name_len: int = 32, **kwargs):
		super().__init__(name="bt-row", **kwargs)
		self.device = device
		self.device.connect("changed", self.on_changed)
		self.device.connect(
			"notify::closed", lambda *_: self.device.closed and self.destroy()
		)

		self.connection_label = Label(label="Disconnected", name="bt-status")
		self.connect_button = Button(
			label="Connect",
			on_clicked=lambda *_: self.device.set_connecting(not self.device.connected),
		)

		self.start_children = Box(
			orientation="h",
			spacing=8,
			style="min-width: 0px",
			children=[
				Image(icon_name=device.icon_name + "-symbolic", icon_size=icon_size),
				Label(label=truncate_text(device.name, max_name_len), name="bt-name"),
			],
		)
		self.center_children = Box(
			orientation="h",
			style="min-width: 0px",
			children=self.connection_label,
		)
		self.end_children = self.connect_button

		self.device.emit("changed")

	def on_changed(self, *_):
		if self.device.connected:
			self.connection_label.set_label("Connected")
			self.connection_label.set_style("color: var(--success)")
		else:
			self.connection_label.set_label("Disconnected")
			self.connection_label.set_style("color: var(--danger)")

		if getattr(self.device, "connecting", False):
			self.connect_button.set_label(
				"Disconnecting..." if self.device.connected else "Connecting..."
			)
		else:
			self.connect_button.set_label(
				"Disconnect" if self.device.connected else "Connect"
			)
		return


class BluetoothConnections(Box):
	def __init__(self, **kwargs):
		name = kwargs.pop("name", "bluetooth-container")
		min_width = kwargs.pop("min_width", 520)
		list_height = kwargs.pop("list_height", 200)
		icon_size = kwargs.pop("icon_size", 22)
		font_size = kwargs.pop("font_size", None)
		max_name_len = kwargs.pop("max_name_len", 32)
		style = f"margin: 8px; min-width: {min_width}px"
		if font_size:
			style = style + f"; font-size: {font_size}px"

		super().__init__(
			spacing=10,
			orientation="vertical",
			style=style,
			name=name,
			**kwargs,
		)

		self.icon_size = icon_size
		self.max_name_len = max_name_len

		self.client = BluetoothClient(on_device_added=self.on_device_added)
		self.scan_button = Button(on_clicked=self._on_scan_clicked)
		self.toggle_button = Button(on_clicked=self._on_power_clicked)

		self.client.connect(
			"notify::enabled",
			lambda *_: self.toggle_button.set_label(
				"Bluetooth " + ("ON" if self.client.enabled else "OFF")
			),
		)
		self.client.connect(
			"notify::scanning",
			lambda *_: self.scan_button.set_label(
				"Stop" if self.client.scanning else "Scan"
			),
		)

		# Update layout when bluetooth power state changes
		self.client.connect("notify::enabled", lambda *_: self._update_layout())

		self.toggle_button.set_label("Bluetooth " + ("ON" if self.client.enabled else "OFF"))
		self.scan_button.set_label("Stop" if self.client.scanning else "Scan")

		self.paired_box = Box(spacing=8, orientation="vertical", name="bluetooth-paired", style="min-width: 0px")
		self.available_box = Box(spacing=8, orientation="vertical", name="bluetooth-available", style="min-width: 0px")

		# Persistent header and body widgets to avoid reparenting issues
		self.header = CenterBox(name="bluetooth-header", end_children=self.toggle_button)
		self.paired_label = Label(label="Paired Devices", name="bluetooth-section-title")
		self.available_label = Label(label="Available Devices", name="bluetooth-section-title")
		self.paired_list = ScrolledWindow(min_content_size=(-1, list_height), child=self.paired_box, name="bluetooth-paired-list")
		self.available_list = ScrolledWindow(min_content_size=(-1, list_height), child=self.available_box, name="bluetooth-available-list")

		self._update_layout()

		self.populate_initial_devices()
		self.client.notify("scanning")
		self.client.notify("enabled")

	def _on_scan_clicked(self, *_):
		try:
			getattr(self.client, "toggle_scan")()
		except Exception:
			pass

	def _on_power_clicked(self, *_):
		try:
			getattr(self.client, "toggle_power")()
		except Exception:
			pass

	def populate_initial_devices(self):
		try:
			devices = getattr(self.client, "_devices", {})
			for addr, dev in devices.items():
				self.on_device_added(self.client, addr)
		except Exception:
			pass

	def on_device_added(self, client, address: str):
		if not (device := client.get_device(address)):
			return
		slot = BluetoothDeviceSlot(device, icon_size=self.icon_size, max_name_len=self.max_name_len)

		if getattr(device, "paired", False):
			self.paired_box.add(slot)
		else:
			self.available_box.add(slot)
		try:
			self.show_all()
		except Exception:
			pass
		return

	def _update_layout(self):
		try:
			enabled = bool(getattr(self.client, "enabled", False))
			# Keep toggle button always visible
			self.header.end_children = self.toggle_button
			self.header.start_children = self.scan_button if enabled else None
			if enabled:
				self.children = [
					self.header,
					self.paired_label,
					self.paired_list,
					self.available_label,
					self.available_list,
				]
			else:
				self.children = [self.header]
			self.show_all()
		except Exception:
			pass


class StatusBar(Window):
	def __init__(
		self,
	):
		super().__init__(
			name="bar",
			layer="top",
			anchor="left top right",
			margin="10px 10px -2px 10px",
			exclusivity="auto",
			visible=False,
		)

		# CPU/RAM progress with tooltip updates
		self.cpu_progress = CircularProgressBar(
			name="cpu-progress-bar",
			pie=True,
			child=Image(icon_name="cpu-symbolic", icon_size=12),
			size=24,
		).build(
			lambda progres: Fabricator(
				interval=1000,
				poll_from=lambda f: psutil.cpu_percent() / 100,
				on_changed=lambda _, value: progres.set_value(value),
			)
		)
		self.ram_progress = CircularProgressBar(
			name="ram-progress-bar",
			pie=True,
			child=self.cpu_progress,
			size=24,
		).build(
			lambda progres: Fabricator(
				interval=1000,
				poll_from=lambda f: psutil.virtual_memory().percent / 100,
				on_changed=lambda _, value: progres.set_value(value),
			)
		)

		# Initialize and periodically update tooltip texts for CPU/GPU stats
		try:
			initial_tip = build_status_tooltip()
			self.cpu_progress.set_tooltip_text(initial_tip)
			self.ram_progress.set_tooltip_text(initial_tip)
		except Exception:
			pass

		self.ram_progress.build(
			lambda _: Fabricator(
				interval=2000,
				poll_from=lambda f: build_status_tooltip(),
				on_changed=lambda _, text: (
					self.cpu_progress.set_tooltip_text(text),
					self.ram_progress.set_tooltip_text(text),
					self.system_status.set_tooltip_text(text),
				),
			)
		)

		self.system_status = Box(
			name="system-status",
			spacing=4,
			orientation="h",
			children=[self.ram_progress]
			+ ([VolumeWidget()] if AUDIO_WIDGET else []),
		)
		# Also apply tooltip to the whole system-status box so hover works anywhere
		try:
			self.system_status.set_tooltip_text(build_status_tooltip())
		except Exception:
			pass

		# compute responsive sizes based on screen
		screen = Gdk.Screen.get_default()
		try:
			screen_width = int(screen.get_width())
			screen_height = int(screen.get_height())
		except Exception:
			screen_width = 1920
			screen_height = 1080
		container_min_width = max(500, int(screen_width * 0.34))
		list_height = max(200, int(screen_height * 0.28))
		icon_size = min(30, max(18, int(screen_width * 0.013)))
		font_size = min(20, max(14, int(16 * screen_width / 1920)))
		max_name_len = 28 if container_min_width < 560 else 36

		if BLUETOOTH_WIDGET:
			self.bluetooth_window = Window(
				name="bluetooth",
				layer="top",
				anchor="top right",
				margin="10px 10px 0 0",
				visible=False,
				child=BluetoothConnections(
					name="bluetooth-root",
					min_width=container_min_width,
					list_height=list_height,
					icon_size=icon_size,
					font_size=font_size,
					max_name_len=max_name_len,
				),
			)
			self.bluetooth_button = Button(
				child=Image(icon_name="bluetooth-symbolic", icon_size=14),
				on_clicked=self.toggle_bluetooth_popup,
			)
		else:
			self.bluetooth_window = None
			self.bluetooth_button = Button(
				child=Image(icon_name="bluetooth-symbolic", icon_size=14),
				on_clicked=lambda *_: subprocess.Popen(["blueman-manager"]),
			)

		self.children = CenterBox(
			name="bar-inner",
			start_children=Box(
				name="start-container",
				children=HyprlandWorkspaces(
					name="workspaces",
					spacing=4,
					buttons_factory=lambda ws_id: WorkspaceButton(id=ws_id, label=None),
				),
			),
			center_children=Box(
				name="center-container",
				children=HyprlandActiveWindow(name="hyprland-window"),
			),
			end_children=Box(
				name="end-container",
				spacing=4,
				orientation="h",
				children=[
					self.system_status,
					self.bluetooth_button,
					SystemTray(name="system-tray", spacing=4),
					DateTime(name="date-time"),
					HyprlandLanguage(
						name="hyprland-window",
						formatter=FormattedString(
							"{replace_lang(language)}",
							replace_lang=lambda lang: bulk_replace(
								lang,
								(r".*Eng.*", r".*Ru.*"),
								("ENG", "RUS"),
								regex=True,
							),
						),
					),
				],
			),
		)

		return self.show_all()

	def toggle_bluetooth_popup(self, *_):
		try:
			is_visible = bool(getattr(self.bluetooth_window, "visible", False))
		except Exception:
			is_visible = False
		if not is_visible:
			try:
				self.bluetooth_window.show_all()
			except Exception:
				pass
			self.bluetooth_window.visible = True
			return
		try:
			self.bluetooth_window.hide()
		except Exception:
			pass
		self.bluetooth_window.visible = False


if __name__ == "__main__":
	bar = StatusBar()
	app = Application("bar", bar)
	app.set_stylesheet_from_file(get_relative_path("./style.css"))

	app.run()