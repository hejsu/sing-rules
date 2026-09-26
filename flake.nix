{
  description = "Sing-Box Rulesets compiler";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    for-all-system = f: nixpkgs.lib.genAttrs
      systems (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = for-all-system (pkgs: {
      default = pkgs.stdenvNoCC.mkDerivation {
        name = "singbox-rulesets";
        src = ./.;

        nativeBuildInputs = [ pkgs.sing-box ];

        installPhase = ''
          for f in $(find rules sukka -name "*.json" 2>/dev/null); do
            target="$out/''${f%.json}.srs"
            mkdir -p "$(dirname "$target")"
            sing-box rule-set compile "$f" -o "$target"
          done
        '';
      };
    });

    devShells = for-all-system (pkgs: {
      default = pkgs.mkShell {
        packages = [ pkgs.sing-box ];
      };
    });
  };
}