{ pkgs }: {
  deps = [
    pkgs.luajitPackages.luarocks
    pkgs.lua5_4_compat
    pkgs.lua-language-server
  ];
}