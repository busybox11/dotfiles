{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  ripgrep,
  metadata,
}:
let
  pkg = lib.importJSON metadata.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "opencode2";
  version = pkg.version;

  src = fetchurl {
    url = pkg.dist.tarball;
    hash = pkg.dist.integrity;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode2 $out/bin/.opencode2-unwrapped
    makeBinaryWrapper $out/bin/.opencode2-unwrapped $out/bin/opencode2 \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
    runHook postInstall
  '';

  meta = {
    description = "OpenCode 2 beta (opencode2); sits next to v1's opencode";
    homepage = "https://opencode.ai/v2/docs";
    license = lib.licenses.mit;
    mainProgram = "opencode2";
    platforms = builtins.attrNames metadata;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
