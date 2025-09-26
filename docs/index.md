# NixOS Gaming Dotfiles

Современная конфигурация NixOS с поддержкой игр и графических планшетов.

## 🎮 Особенности

### Gaming Support
- **osu!** - osu-lazer-bin и osu-stable через Wine
- **Steam** - полная поддержка Steam игр
- **Wine** - оптимизированный Wine для игр
- **nix-gaming** - коллекция игровых пакетов

### Tablet Support
- **OpenTabletDriver** - поддержка графических планшетов
- **Wacom** - драйверы для планшетов Wacom

### Desktop Environment
- **Hyprland** - современный Wayland композитор
- **EWW** - виджеты для рабочего стола
- **Rofi** - лаунчер приложений
- **Starship** - красивая командная строка

### Audio
- **PipeWire** - современный аудио сервер
- **Низкая задержка** - оптимизация для игр

## 🚀 Быстрый старт

```bash
# Клонируйте репозиторий
git clone https://github.com/pyw0w/.dotfiles.git
cd .dotfiles

# Пересоберите систему
sudo nixos-rebuild switch --flake .#desktop
```

## �� Структура проекта

```
├── modules/           # Модули конфигурации
│   ├── base/         # Базовые настройки
│   ├── hyprland/     # Hyprland конфигурация
│   ├── nvidia.nix    # NVIDIA драйверы
│   └── opentabletdriver.nix # Поддержка планшетов
├── devices/          # Конфигурации устройств
│   ├── desktop/      # Настройки для десктопа
│   └── laptop/       # Настройки для ноутбука
└── packages/         # Кастомные пакеты
```

## 🎯 Поддерживаемые устройства

- **Desktop** - игровой ПК с NVIDIA GPU
- **Laptop** - ноутбук с гибридной графикой

## 🔧 Настройка

### Включение модулей

```nix
# В modules/default.nix
{
  imports = [
    ./nvidia.nix           # NVIDIA драйверы
    ./opentabletdriver.nix # Поддержка планшетов
  ];
}
```

### Добавление игр

```nix
# В modules/base/default.nix
environment.systemPackages = with pkgs; [
  # osu! игры из nix-gaming
  inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin
  inputs.nix-gaming.packages.${pkgs.system}.osu-stable
];
```

## 📦 Используемые пакеты

### Игры
- `osu-lazer-bin` - современная версия osu!
- `osu-stable` - классическая версия через Wine
- `steam` - Steam клиент

### Инструменты разработки
- `python` - Python с необходимыми пакетами
- `nodejs` - Node.js для веб-разработки
- `docker` - Docker контейнеры
- `ollama` - локальные LLM модели

### Системные утилиты
- `fish` - современная командная оболочка
- `starship` - красивая командная строка
- `fastfetch` - системная информация

## 🎨 Скриншоты

*Скриншоты будут добавлены позже*

## 🤝 Вклад в проект

Приветствуются:
- Pull requests с улучшениями
- Issues с багами и предложениями
- Документация и примеры использования

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE)

## 🔗 Полезные ссылки

- [NixOS](https://nixos.org/) - операционная система
- [Hyprland](https://hyprland.org/) - Wayland композитор
- [nix-gaming](https://github.com/fufexan/nix-gaming) - игровые пакеты
- [OpenTabletDriver](https://opentabletdriver.net/) - драйвер планшетов
