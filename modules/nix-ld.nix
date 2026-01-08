{ 
  pkgs,
  ... 
}:
{
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