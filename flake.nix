{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    lib = import ./lib nixpkgs.lib;

    packages.x86_64-linux.docs =
      (self.lib.mkDocs {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      })
      .optionsAsciiDoc;

    flakeModule = import ./flake-module.nix self;
  };
}
