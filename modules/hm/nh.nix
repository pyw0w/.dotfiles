{ pkgs, ... }:

{
  # Удобные алиасы для nh
  programs.zsh.shellAliases = {
    # Основные команды nh
    "ns" = "nh os switch";
    "nsw" = "nh os switch --dry";
    "nsv" = "nh os switch --verbose";
    "nsa" = "nh os switch --ask";
    
    # Команды для boot
    "nb" = "nh os boot";
    "nbw" = "nh os boot --dry";
    
    # Команды для тестирования
    "nt" = "nh os test";
    "ntw" = "nh os test --dry";
    
    # Команды для сборки
    "nbuild" = "nh os build";
    "nbuildw" = "nh os build --dry";
    
    # Команды для очистки
    "nc" = "nh clean all";
    "ncw" = "nh clean all --dry";
    "nc3" = "nh clean all --keep 3";
    "nc5" = "nh clean all --keep 5";
    "nc7" = "nh clean all --keep 7";
    
    # Команды для информации
    "ni" = "nh os info";
    "nsearch" = "nh search";
    
    # Команды для home-manager
    "nh" = "nh home switch";
    "nhw" = "nh home switch --dry";
    "nhv" = "nh home switch --verbose";
    
    # Быстрые команды с подробным выводом
    "nsw-detailed" = "NIX_DEBUG=1 NIX_SHOW_STATS=1 nh os switch --no-nom";
  };

  # Функции для nh
  programs.zsh.initContent = ''
    # Функция для быстрого переключения с прогрессом
    nsw-progress() {
      echo "🚀 Начинаю переключение системы..."
      echo "📊 Время начала: $(date)"
      
      if nh os switch; then
        echo "✅ Переключение завершено успешно!"
        echo "📊 Время завершения: $(date)"
        echo "💾 Размер системы: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Ошибка при переключении!"
        return 1
      fi
    }

    # Функция для очистки с информацией
    nc-info() {
      local keep="$1"
      if [[ -z "$keep" ]]; then
        keep=3
      fi
      
      echo "🧹 Начинаю очистку системы..."
      echo "📊 Оставляю $keep поколений"
      echo "💾 Размер до очистки: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      
      if nh clean all --keep "$keep"; then
        echo "✅ Очистка завершена!"
        echo "💾 Размер после очистки: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Ошибка при очистке!"
        return 1
      fi
    }

    # Функция для поиска с форматированием
    nsearch-pretty() {
      if [[ -z "$1" ]]; then
        echo "🔍 Использование: nsearch-pretty <пакет>"
        return 1
      fi
      
      echo "🔍 Поиск пакета: $1"
      echo "⏱️  Время поиска: $(date)"
      
      nh search "$1" | head -20
      
      echo "✅ Поиск завершен!"
    }

    # Функция для мониторинга системы
    n-monitor() {
      echo "📊 Информация о системе NixOS:"
      echo "================================"
      echo "🏗️  Текущая система: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      echo "📅 Поколения:"
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
      echo "🧹 Доступное место: $(df -h /nix | tail -1 | awk '{print $4}')"
      echo "================================"
    }

    # Функция для быстрого обновления
    n-update() {
      echo "🔄 Обновляю flake inputs..."
      if nh os switch --update; then
        echo "✅ Обновление завершено!"
        n-monitor
      else
        echo "❌ Ошибка при обновлении!"
        return 1
      fi
    }

    # Автодополнение для nh команд
    _nh_completion() {
      local cur="$2"
      local prev="$3"
      
      case "$prev" in
        "ns"|"nsw"|"nsf"|"nsv"|"nsa")
          COMPREPLY=( $(compgen -W "--dry --fast --verbose --ask --no-nom --update" -- "$cur") )
          ;;
        "nc"|"ncw"|"nc3"|"nc5"|"nc7")
          COMPREPLY=( $(compgen -W "--keep --dry --ask --verbose" -- "$cur") )
          ;;
        "nsearch"|"nsearch-pretty")
          COMPREPLY=( $(compgen -W "firefox vscode python nodejs" -- "$cur") )
          ;;
      esac
    }
    
    complete -F _nh_completion ns nsw nsf nsv nsa nc ncw nc3 nc5 nc7 nsearch nsearch-pretty
  '';

  # Переменные окружения для nh
  home.sessionVariables = {
    # Подробный вывод по умолчанию
    NIX_DEBUG = "1";
    NIX_SHOW_STATS = "1";
    NH_VERBOSE = "1";
    
    # Цветной вывод
    NIX_COLORS = "ca=01;31:di=01;36:ex=01;32:ln=01;35:or=01;41:ow=01;33:pi=01;35:so=01;32:st=01;37:su=01;31:sg=01;46:tw=01;31:tw=01;46";
  };
} 