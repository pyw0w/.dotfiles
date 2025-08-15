args@{ pkgs, variables, ... }:
{
  environment.systemPackages = with pkgs; [
    # jetbrains.rider removed - no longer needed
    dotnet-sdk_8
  ];
}