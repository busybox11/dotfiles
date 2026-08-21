inputs: final: prev: {
  opencode2 = prev.callPackage ../pkgs/opencode2.nix {
    metadata = {
      x86_64-linux = inputs.opencode2-linux-x64;
      aarch64-linux = inputs.opencode2-linux-arm64;
      x86_64-darwin = inputs.opencode2-darwin-x64;
      aarch64-darwin = inputs.opencode2-darwin-arm64;
    };
  };
}
