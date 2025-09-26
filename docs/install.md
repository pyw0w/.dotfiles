# Установка

Пошаговое руководство по установке и настройке.

## Предварительные требования

- NixOS 25.05 или новее
- Минимум 8GB RAM
- NVIDIA GPU (для игр)
- Графический планшет (опционально)

## Быстрая установка

### 1. Клонирование репозитория

```bash
git clone https://github.com/pyw0w/.dotfiles.git
cd .dotfiles
```

### 2. Пересборка системы

```bash
sudo nixos-rebuild switch --flake .#desktop
```

### 3. Перезагрузка

```bash
sudo reboot
```

## Детальная установка

### Настройка для разных устройств

#### Desktop (игровой ПК)
```bash
sudo nixos-rebuild switch --flake .#desktop
```

#### Laptop (ноутбук)
```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Первоначальная настройка

После установки выполните:

1. **Настройка пользователя**
   ```bash
   # Создайте пользователя (если нужно)
   sudo useradd -m -s /bin/fish pyw0w
   sudo usermod -aG wheel pyw0w
   ```

2. **Настройка SSH**
   ```bash
   # Скопируйте SSH ключи
   mkdir -p ~/.ssh
   # Добавьте ваши SSH ключи
   ```

3. **Настройка Git**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## Проверка установки

### Проверка игр
```bash
# Проверьте доступность osu!
which osu-lazer-bin
which osu-stable
```

### Проверка планшета
```bash
# Проверьте OpenTabletDriver
systemctl status opentabletdriver
```

### Проверка NVIDIA
```bash
# Проверьте драйверы NVIDIA
nvidia-smi
```

## Устранение проблем

### Проблемы с играми
- Убедитесь, что включен `allowUnfree = true`
- Проверьте, что установлены необходимые библиотеки

### Проблемы с планшетом
- Проверьте подключение USB
- Убедитесь, что OpenTabletDriver запущен

### Проблемы с NVIDIA
- Проверьте совместимость драйверов
- Убедитесь, что GPU поддерживается
