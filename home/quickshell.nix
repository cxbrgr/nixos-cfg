{ pkgs, quickshell, ... }:

# Access the Quickshell package from the flake input
let qs = quickshell.packages.x86_64-linux.default;

in pkgs.stdenv.mkDerivation {
  name = "illogical-impulse-quickshell-wrapper";
  meta = with pkgs.lib; {
    description = "Quickshell bundled Qt deps for home-manager usage";
    license = licenses.gpl3Only;
  };

  # Dependency packaging - no unpacking or building needed as we use the prebuilt binary from the flake
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # Tools needed for wrapping the application
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.qt6.wrapQtAppsHook
  ];

  # Runtime dependencies required for Quickshell and its Qt/KDE integration
  buildInputs = with pkgs; [
    qs
    # Wayland support for Qt
    kdePackages.qtwayland
    # Positioning and location services
    kdePackages.qtpositioning
    kdePackages.qtlocation
    # Syntax highlighting for code views
    kdePackages.syntax-highlighting
    # GSettings schemas for desktop integration
    gsettings-desktop-schemas
    # Core Qt6 modules
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qt5compat
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtquicktimeline
    qt6.qtsensors
    qt6.qtsvg
    qt6.qttools
    qt6.qttranslations
    qt6.qtvirtualkeyboard
    qt6.qtwayland
    # KDE Frameworks
    kdePackages.kirigami
    kdePackages.kdialog
  ];

  # Install phase: Wrap the binary with XDG_DATA_DIRS to ensure it finds necessary schemas
  installPhase = ''
    mkdir -p $out/bin
    # Verify binary exists
    ls -l ${qs}/bin || true
    
    # Wrap the 'qs' binary
    makeWrapper ${qs}/bin/qs $out/bin/qs \
      --prefix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name} \
      --suffix XDG_DATA_DIRS : /var/run/current-system/sw/share \
      --suffix XDG_DATA_DIRS : /nix/var/nix/profiles/default/share \
      --suffix XDG_DATA_DIRS : $HOME/.nix-profile/share
      
    chmod +x $out/bin/qs
  '';
}
