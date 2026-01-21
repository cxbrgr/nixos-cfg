{ 
  pkgs,
  ... 
}:
{
  # Run unpatched dynamic binaries on NixOS.
  # https://github.com/nix-community/nix-ld

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
    glib

    # IDE server dependencies
    curl
    libuuid
    libsecret
    libunwind
    lttng-ust
    util-linux
  ];
}