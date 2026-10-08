# zoetrope (`zoe`): draws a coding agent's session as a live flow graph.
# Its herdr plugin, linked from the same release's source, only launches
# `zoe` (and reads herdr's JSON with jq). `prefix+shift+z` opens the graph
# split beside the focused agent pane and closes it again; the overlay and
# tab placements stay plugin actions. The release binaries are static
# (musl), so they run on NixOS as shipped. Bump `version`, both binary
# hashes (the release's .sha512 files) and the source hash together.
{ ... }:
{
  den.aspects.home-zoetrope.provides.to-users.homeManager =
    { pkgs, ... }:
    let
      version = "0.2.0";
      targets = {
        x86_64-linux = {
          arch = "x86_64";
          hash = "sha512-I5ljTmxDulzMpqTLEN9BEsptJ98TISF0iobQFugW9VD6mhdvBV7hCVxu+zOMaQ5QH7BWiEnPAYbjBytNlgwoEw==";
        };
        aarch64-linux = {
          arch = "aarch64";
          hash = "sha512-7NEFR8gao9XL8deo8U9bDO/POr4C98W5YciYtrc6uvD0j5szh9RdPUBL2/vjFOBUepoYd97U1L/fzYGHlyfEBA==";
        };
      };
      target = targets.${pkgs.stdenv.hostPlatform.system};
      zoe = pkgs.stdenvNoCC.mkDerivation {
        pname = "zoetrope";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/furkankly/zoetrope/releases/download/v${version}/zoetrope-${version}-${target.arch}-unknown-linux-musl.tar.gz";
          inherit (target) hash;
        };
        installPhase = ''
          runHook preInstall
          install -Dm755 zoe $out/bin/zoe
          runHook postInstall
        '';
        meta = {
          description = "Live flow graph of a coding agent's session";
          homepage = "https://github.com/furkankly/zoetrope";
          license = pkgs.lib.licenses.mit;
          mainProgram = "zoe";
          sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
        };
      };
      src = pkgs.fetchFromGitHub {
        owner = "furkankly";
        repo = "zoetrope";
        tag = "v${version}";
        hash = "sha256-jfzbgtZNIbDyHpXqP5QxF9o71zdYKEbY862NIaPHujo=";
      };
    in
    {
      home.packages = [
        zoe
        pkgs.jq
      ];

      herdr.plugins."furkankly.zoetrope" = "${src}/herdr-plugin";
      herdr.settings.keys.command = [
        {
          key = "prefix+shift+z";
          type = "plugin_action";
          command = "furkankly.zoetrope.open-split";
          description = "zoetrope: session graph (split)";
        }
      ];
    };
}
