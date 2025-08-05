{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Screen management tools
    brightnessctl
    wlr-randr
  ];

  # Create custom scripts for screen management
  home.file.".local/bin/screen-off" = {
    text = ''
      #!/bin/bash
      # Turn off screen
      hyprctl dispatch dpms off
    '';
    executable = true;
  };

  home.file.".local/bin/screen-on" = {
    text = ''
      #!/bin/bash
      # Turn on screen
      hyprctl dispatch dpms on
    '';
    executable = true;
  };

  home.file.".local/bin/toggle-screen" = {
    text = ''
      #!/bin/bash
      # Toggle screen on/off
      if hyprctl monitors | grep -q "dpmsStatus: 1"; then
        hyprctl dispatch dpms off
      else
        hyprctl dispatch dpms on
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/disable-screen-blanking" = {
    text = ''
      #!/bin/bash
      # Disable screen blanking
      hyprctl dispatch dpms on
      # Set brightness to maximum if brightnessctl is available
      if command -v brightnessctl &> /dev/null; then
        brightnessctl set 100%
      fi
      echo "Screen blanking disabled"
    '';
    executable = true;
  };

  # NixOS monitoring scripts
  home.file.".local/bin/nix-status" = {
    text = ''
      #!/bin/bash
      echo "📊 NixOS System Status"
      echo "======================"
      echo "🏗️  System size: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      echo "📅 Generations:"
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
      echo "💾 Available space: $(df -h /nix | tail -1 | awk '{print $4}')"
      echo "======================"
    '';
    executable = true;
  };

  home.file.".local/bin/nix-clean" = {
    text = ''
      #!/bin/bash
      KEEP="$1"
      if [[ -z "$KEEP" ]]; then
        KEEP=3
      fi
      
      echo "🧹 Cleaning NixOS system..."
      echo "📊 Keeping $KEEP generations"
      echo "💾 Size before: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      
      if nh clean all --keep "$KEEP"; then
        echo "✅ Cleanup completed!"
        echo "💾 Size after: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Cleanup failed!"
        exit 1
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/nix-switch-fast" = {
    text = ''
      #!/bin/bash
      echo "🚀 Starting system switch..."
      echo "📊 Start time: $(date)"
      
      if nh os switch; then
        echo "✅ Switch completed successfully!"
        echo "📊 End time: $(date)"
        echo "💾 System size: $(nix path-info --closure-size /run/current-system | numfmt --to=iec)"
      else
        echo "❌ Switch failed!"
        exit 1
      fi
    '';
    executable = true;
  };

  # CUDA management scripts
  home.file.".local/bin/cuda-status" = {
    text = ''
      #!/bin/bash
      echo "🔧 CUDA Status Check"
      echo "==================="
      
      # Check NVIDIA driver
      echo "📊 NVIDIA Driver:"
      nvidia-smi 2>/dev/null || echo "❌ NVIDIA driver not working"
      
      # Check CUDA installation
      echo ""
      echo "⚡ CUDA Installation:"
      if command -v nvcc &> /dev/null; then
        echo "✅ CUDA Compiler: $(nvcc --version | head -1)"
        echo "📍 CUDA Path: $CUDA_HOME"
      else
        echo "❌ CUDA compiler not found"
      fi
      
      # Check PyTorch CUDA
      echo ""
      echo "🧠 PyTorch CUDA:"
      python3 -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU count: {torch.cuda.device_count()}')" 2>/dev/null || echo "❌ PyTorch not available"
      
      echo "==================="
    '';
    executable = true;
  };

  home.file.".local/bin/cuda-test" = {
    text = ''
      #!/bin/bash
      echo "🧪 CUDA Test Suite"
      echo "=================="
      
      # Test CUDA samples
      if [[ -d "$CUDA_HOME/samples" ]]; then
        echo "📁 CUDA Samples found at: $CUDA_HOME/samples"
        echo "🔍 Available samples:"
        find "$CUDA_HOME/samples" -name "*.cu" | head -5
      else
        echo "❌ CUDA samples not found"
      fi
      
      # Test PyTorch CUDA
      echo ""
      echo "🧠 Testing PyTorch CUDA:"
      python3 -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB')
    # Test tensor operations
    x = torch.randn(1000, 1000).cuda()
    y = torch.randn(1000, 1000).cuda()
    z = torch.mm(x, y)
    print('✅ CUDA tensor operations working')
else:
    print('❌ CUDA not available in PyTorch')
" 2>/dev/null || echo "❌ PyTorch test failed"
      
      echo "=================="
    '';
    executable = true;
  };

  home.file.".local/bin/cuda-monitor" = {
    text = ''
      #!/bin/bash
      echo "📊 CUDA GPU Monitor"
      echo "==================="
      
      # Monitor GPU usage
      watch -n 1 'nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits'
    '';
    executable = true;
  };
} 