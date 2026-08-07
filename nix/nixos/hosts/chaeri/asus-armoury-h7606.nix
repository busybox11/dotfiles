{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "asus-armoury-h7606";
  inherit (kernel) src version;

  patches = [ ./patches/asus-armoury-dgpu-fallback.patch ];

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  # Distinct module name so the in-tree asus-armoury can be blacklisted
  # kernel.dev headers lack the pending ASUS_WMI_DEVID_GPU_MODE define
  postPatch = ''
        mkdir -p "$NIX_BUILD_TOP/module"
        cp drivers/platform/x86/asus-armoury.c \
           drivers/platform/x86/asus-armoury.h \
           drivers/platform/x86/firmware_attributes_class.h \
           "$NIX_BUILD_TOP/module/"
        mv "$NIX_BUILD_TOP/module/asus-armoury.c" \
           "$NIX_BUILD_TOP/module/asus-armoury-h7606.c"

        cat > "$NIX_BUILD_TOP/module/Makefile" <<'EOF'
    obj-m += asus-armoury-h7606.o
    ccflags-y += -DASUS_WMI_DEVID_GPU_MODE=0x00090120
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
      M="$NIX_BUILD_TOP/module" \
      ${toString kernelModuleMakeFlags} \
      modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D "$NIX_BUILD_TOP/module/asus-armoury-h7606.ko" \
      "$out/lib/modules/${kernel.modDirVersion}/extra/asus-armoury-h7606.ko"
    runHook postInstall
  '';

  meta = {
    description = "asus-armoury with ProArt H7606 dGPU DEVID fallback";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
