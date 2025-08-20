{
  lib,
  fetchFromGitHub,
  python3Packages,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  pkg-config,
  wrapGAppsHook3,
}:

python3Packages.buildPythonPackage {
  pname = "python-fabric";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "0d82275169d3d6ff9cde25eac8bbd754a3dfeddf";
    sha256 = "sha256-DcEz9zegSMIaWObOT+d8VQC2fkPyZkeiz69+QdaxwQQ=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    cairo
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
    libdbusmenu-gtk3
    gdk-pixbuf
  ];

  propagatedBuildInputs = with python3Packages; [
    setuptools
    wheel
    click
    pycairo
    pygobject3
    pygobject-stubs
    loguru
    psutil
    python-dbusmock
    dbus-python
  ];

  pythonImportsCheck = [ "fabric" ];

  meta = {
    changelog = "";
    description = ''
      next-gen framework for building desktop widgets using Python (check the rewrite branch for progress)
    '';
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}