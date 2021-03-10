{ stdenv, buildFHSUserEnv, requireFile, dpkg, gnutar, autoPatchelfHook, ... }:

  # dbus_daemon, nss, mesa_noglu, xlibs, cups, cairo, pango, alsaLib, at_spi2_core,
  # at-spi2-atk, gtk3, libgccjit, ... }:
  

let unwrapped = stdenv.mkDerivation rec {
      pname = "microsoft-edge-dev";
      version = "90.0.810.1-1";

      src = requireFile rec {
        name = "${pname}_${version}_amd64.deb";
        sha256 = "06m0d1c67ynb1zj5i5y07c833kbrjh7246d3axfja1d0yvv4mawi";

        message = ''
          In order to use Microsoft Edge, you need to comply with the Microsoft Edge
          and download the DEB package from https://www.microsoftedgeinsider.com/de-de/download/.

          If you can not find the required version there please open an issue at my
          https://github.com/NobbZ/nix-dotfiles.

          Once you have downloaded the file, please use the following command then
          re-run the installation:

          nix-prefetch-url file://\$HOME/Downloads/${name}
      '';
      };

      nativeBuildInputs = [
       # autoPatchelfHook
      ];

      # buildInputs = [
      #   dbus_daemon.lib nss mesa_noglu cups.lib cairo pango alsaLib at_spi2_core
      #   at-spi2-atk gtk3 libgccjit
      # ] ++ (with xlibs; [ libXfixes libXcomposite libXrandr libxshmfence ]);

      unpackPhase = ''
        mkdir $out
        ${dpkg}/bin/dpkg --fsys-tarfile $src | ${gnutar}/bin/tar xv -C $out
      '';

      patchPhase = ''
        substituteInPlace $out/usr/share/applications/microsoft-edge-dev.desktop \
          --replace 'Exec=/usr/bin/microsoft-edge-dev' "Exec=$out/bin/microsoft-edge-dev"
      '';

      installPhase = ''
        mkdir -p $out/bin
        ln -s $out/opt/microsoft/msedge-dev/microsoft-edge-dev $out/bin/microsoft-edge-dev
      '';
    };

in buildFHSUserEnv rec {
  name = "microsoft-edge-dev-90.0.810.1-1";
  targetPkgs = pkgs: [
    unwrapped
  ]++ (with pkgs; [
    dbus_daemon.lib nss mesa_noglu cups.lib cairo pango alsaLib at_spi2_core
    at-spi2-atk gtk3 libgccjit
  ] ++ (with xlibs; [ libXfixes libXcomposite libXrandr libxshmfence ]));
  multiPkgs = pkgs: [];
  runScript = "microsoft-edge-dev";
}
