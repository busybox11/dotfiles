final: prev: {
  python3 = prev.python3.override {
    packageOverrides = pyfinal: pyprev: {
      dlib = pyprev.dlib.overrideAttrs {
        patches = [ ./dlib-build-cores.patch ];
        preConfigure = "";
      };
    };
  };
  python3Packages = final.python3.pkgs;
}
