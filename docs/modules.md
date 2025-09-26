# Модули

Описание всех модулей конфигурации.

## Базовые модули

### base/default.nix
Основные системные настройки:
- Часовой пояс: Asia/Yekaterinburg
- Языковые настройки (en_US, ru_RU)
- Базовые пакеты (wget, nano, jq, lsd, bat, fzf)
- Настройки пользователя и групп
- Cachix для ускорения сборок

### base/gui/default.nix
Графический интерфейс:
- X11 и Wayland поддержка
- Шрифты и темы
- Базовые GUI приложения

## Игровые модули

### nvidia.nix
NVIDIA драйверы и оптимизация:
- Драйвер версии 575.64.05
- Modesetting включен
- Power management для suspend/wakeup
- Kernel параметры для Hyprland
- CUDA toolkit

### opentabletdriver.nix
Поддержка графических планшетов:
- Включает OpenTabletDriver
- Поддержка Wacom и других планшетов

## Приложения

### hyprland/default.nix
Hyprland конфигурация:
- Основные настройки композитора
- Скрипты для управления окнами
- Обои и темы

### eww/
EWW виджеты:
- Системная информация
- Температура и использование ресурсов
- Рабочие пространства
- Батарея (для ноутбуков)

### rofi/
Rofi лаунчер:
- Прозрачная и непрозрачная темы
- Настройки шрифтов и цветов

## Разработка

### devtools.nix
Инструменты разработки:
- Python с пакетами
- Node.js
- Docker
- Ollama для LLM

### fish/default.nix
Fish shell:
- Современная командная оболочка
- Автодополнение
- Плагины

## Системные модули

### bluetooth.nix
Bluetooth поддержка:
- Автоматическое включение
- Управление устройствами

### steam.nix
Steam клиент:
- Полная поддержка Steam
- Игровые библиотеки

## Кастомные пакеты

### packages/
Собственные пакеты:
- ArchiSteamFarm
- DevelNext
- Fabric
- SDDM Sugar Candy

## Настройка модулей

### Включение модуля
```nix
# В modules/default.nix
{
  imports = [
    ./nvidia.nix
    ./opentabletdriver.nix
  ];
}
```

### Отключение модуля
```nix
# В конфигурации устройства
{
  local = {
    nvidia.enable = false;
    opentabletdriver.enable = false;
  };
}
```

### Кастомизация
```nix
# Переопределение настроек
{
  hardware.nvidia.package = pkgs.linuxPackages.nvidiaPackages.stable;
  hardware.opentabletdriver.enable = true;
}
```
