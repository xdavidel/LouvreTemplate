{
  pkgs ?
  # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";

      sha256 = lock.narHash;
    };
  in
    import nixpkgs {},
  ...
}: let
  pname = "louvre-example";
in
  pkgs.stdenv.mkDerivation {
    inherit pname;
    version = "nightly";

    src = builtins.path {
      path = ./.;
      name = "source";
    };

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
    ];

    buildInputs = with pkgs; [
      louvre
      libinput
      libxkbcommon
      pixman
      wayland
      libGL
      libdrm
    ];
    configurePhase = ''
      meson setup build
    '';

    buildPhase = ''
      cd build
      ninja
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv ${pname} $out/bin
    '';

    passthru = {
      providedSessions = [pname];
    };

    meta = {
      mainProgram = pname;
      description = "Wayland compositor based on Louvre";
      homepage = "https://github.com/CuarzoSoftware/Louvre";
      license = pkgs.lib.licenses.mit;
      maintainers = [];
      platforms = pkgs.lib.platforms.unix;
    };
  }
