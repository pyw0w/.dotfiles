{
  inputs,
  ...
}:
{
  system.configurationRevision = inputs.self.rev or "dirty";
} 