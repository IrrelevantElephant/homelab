{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      allowUnfree = true;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "can-finder-shell";

        packages = with pkgs; [
          argocd
          cloudflared
          k9s
          kubernetes-helm
        ];
      };
    };
}
