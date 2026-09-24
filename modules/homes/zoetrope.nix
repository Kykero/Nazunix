# zoetrope (`zoe`): draws a coding agent's session as a live flow graph.
# Its herdr plugin only launches `zoe`; the plugin's install step looks for
# it on PATH and would otherwise fall back to brew or cargo. The release
# binaries are static (musl), so they run on NixOS as shipped. Bump
# `version` and both hashes (the release's .sha512 files) together.
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
    in
    {
      home.packages = [ zoe ];
    };
}
