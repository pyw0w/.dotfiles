# Java и Minecraft 1.20.1 настройка

## Что было добавлено

### Системные пакеты (modules/dev/java.nix)
- **JDK 17** - основная версия для Minecraft 1.20.1
- **JDK 21** - последняя LTS версия, также совместима
- **Gradle** - система сборки для Minecraft модов
- **Maven** - альтернативная система сборки
- **Fabric Installer** - для Fabric модов
- **Forge Installer** - для Forge модов

### Пользовательские настройки (modules/hm/minecraft.nix)
- **PrismLauncher** - современный лаунчер Minecraft с поддержкой модов
- Скрипты для запуска Minecraft с оптимальными настройками Java
- Конфигурация для разработки модов

## Применение изменений

```bash
# Пересобрать конфигурацию
sudo nixos-rebuild switch

# Или используя nh
nh os switch
```

## Проверка установки

### Проверка Java
```bash
# Проверить версию Java
java -version

# Проверить JAVA_HOME
echo $JAVA_HOME

# Проверить доступные версии Java
ls /nix/store/*/bin/java | grep jdk
```

### Проверка Minecraft инструментов
```bash
# Проверить PrismLauncher
prismlauncher --version

# Проверить Gradle
gradle --version

# Проверить Maven
mvn --version
```

## Запуск Minecraft

### Обычный запуск
```bash
# Использовать созданный скрипт
~/.local/bin/minecraft

# Или напрямую
prismlauncher
```

### Запуск для разработки
```bash
# Запуск с настройками для разработки
~/.local/bin/minecraft-dev
```

## Настройка для Minecraft 1.20.1

### Рекомендуемые настройки Java
- **Версия Java**: JDK 17 (рекомендуется) или JDK 21
- **Память**: минимум 2GB, рекомендуется 4-8GB
- **Аргументы JVM**: `-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1`

### Настройка в PrismLauncher
1. Запустите PrismLauncher
2. Создайте новый профиль для Minecraft 1.20.1
3. В настройках профиля:
   - Установите Java 17
   - Настройте память (рекомендуется 4-8GB)
   - Добавьте JVM аргументы выше

## Разработка модов

### Fabric моды
```bash
# Установить Fabric
fabric-installer

# Создать новый проект
gradle init --type fabric-mod
```

### Forge моды
```bash
# Установить Forge
forge-installer

# Создать новый проект
gradle init --type forge-mod
```

## Устранение проблем

### Проблемы с Java
```bash
# Проверить переменные окружения
env | grep JAVA

# Переустановить Java
sudo nixos-rebuild switch
```

### Проблемы с Minecraft
```bash
# Очистить кэш Minecraft
rm -rf ~/.minecraft/assets
rm -rf ~/.minecraft/logs

# Проверить логи
tail -f ~/.minecraft/logs/latest.log
```

### Проблемы с производительностью
```bash
# Проверить использование памяти
free -h

# Проверить загрузку CPU
htop

# Оптимизировать настройки Java
# Используйте аргументы JVM из раздела выше
```

## Дополнительные инструменты

### Полезные команды
```bash
# Переключение между версиями Java
export JAVA_HOME=/nix/store/$(ls /nix/store | grep jdk17 | head -1)
export PATH="$JAVA_HOME/bin:$PATH"

# Проверка совместимости модов
# Используйте PrismLauncher для автоматической проверки

# Создание резервной копии мира
cp -r ~/.minecraft/saves/MyWorld ~/backup/MyWorld_$(date +%Y%m%d)
```

## Откат изменений

Если нужно удалить Java и Minecraft:

1. Закомментируйте импорты в `modules/dev/default.nix`
2. Закомментируйте импорты в `modules/hm/default.nix`
3. Пересоберите конфигурацию
4. Удалите папки Minecraft: `rm -rf ~/.minecraft ~/.local/share/minecraft` 