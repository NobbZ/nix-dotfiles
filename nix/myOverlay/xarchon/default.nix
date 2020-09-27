{ stdenv, lib, x11, libXpm, gtk2, pkgconfig, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "xarchon";
  version = "0.50";

  src = fetchTarball {
    url = "http://xarchon.seul.org/${pname}-${version}.tar.gz";
    sha256 = "09qgbclvc5wpc6nc205999prbdcaxaahjpzjc1ak1ni93sdqzfcz";
  };

  nativeBuildInputs = [ pkgconfig wrapGAppsHook ];
  buildInputs = [ x11 libXpm (lib.getBin gtk2) ];
}
