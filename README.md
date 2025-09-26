# 🎮 NixOS Gaming Dotfiles

[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://pyw0w.github.io/.dotfiles/)
[![NixOS](https://img.shields.io/badge/NixOS-25.05-blue)](https://nixos.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Современная конфигурация NixOS с поддержкой игр и графических планшетов.

## ✨ Особенности

- �� **Gaming**: osu!, Steam, Wine, nix-gaming
- 🎨 **Tablets**: OpenTabletDriver для графических планшетов  
- 🖥️ **Desktop**: Hyprland + EWW виджеты
- 🎵 **Audio**: PipeWire с низкой задержкой
- 🔧 **Dev**: Python, Node.js, Docker, Ollama

## 🚀 Быстрый старт

```bash
git clone https://github.com/pyw0w/.dotfiles.git
cd .dotfiles
sudo nixos-rebuild switch --flake .#desktop
```

## 📖 Документация

📚 **[Полная документация](https://pyw0w.github.io/.dotfiles/)**

- [Установка](https://pyw0w.github.io/.dotfiles/install)
- [Модули](https://pyw0w.github.io/.dotfiles/modules)
- [Конфигурация](https://pyw0w.github.io/.dotfiles/config)

## 🎯 Поддерживаемые устройства

- **Desktop** - игровой ПК с NVIDIA GPU
- **Laptop** - ноутбук с гибридной графикой

## 📁 Структура

```
├── modules/           # Модули конфигурации
│   ├── base/         # Базовые настройки
│   ├── hyprland/     # Hyprland + EWW
│   ├── nvidia.nix    # NVIDIA драйверы
│   └── opentabletdriver.nix # Планшеты
├── devices/          # Конфигурации устройств
├── packages/         # Кастомные пакеты
└── docs/            # GitHub Pages документация
```

## 🎮 Игры

- **osu-lazer-bin** - современная версия osu!
- **osu-stable** - классическая версия через Wine
- **Steam** - полная поддержка Steam игр

## 🎨 Планшеты

- **OpenTabletDriver** - универсальный драйвер
- **Wacom** - поддержка планшетов Wacom
- **Настройка чувствительности** и областей

## 🤝 Вклад в проект

Приветствуются:
- 🐛 Issues с багами
- 💡 Pull requests с улучшениями  
- 📝 Документация и примеры

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE)

## 🔗 Полезные ссылки

- [NixOS](https://nixos.org/) - операционная система
- [Hyprland](https://hyprland.org/) - Wayland композитор
- [nix-gaming](https://github.com/fufexan/nix-gaming) - игровые пакеты
- [OpenTabletDriver](https://opentabletdriver.net/) - драйвер планшетов

---

⭐ **Поставьте звезду, если проект вам понравился!**
