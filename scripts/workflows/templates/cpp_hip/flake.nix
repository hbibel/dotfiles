{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        rocm = pkgs.rocmPackages;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "hip-dev-shell";
          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            clang-tools
          ];

          buildInputs = [
            rocm.hipcc
            rocm.clr 
            rocm.rocminfo
          ];

          shellHook = ''
            export HIP_PATH="${rocm.clr}"
            export CPLUS_INCLUDE_PATH="${rocm.clr}/include:$CPLUS_INCLUDE_PATH"

            # Symlink compile_commands.json to root for clangd detection
            if [ -f build/compile_commands.json ]; then
              ln -sf build/compile_commands.json .
            fi

            echo "Compiler: $(which hipcc)"
          '';
        };
      }
    );
}

