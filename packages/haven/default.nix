{ stdenv, jdk, ant, javaPackages, fetchgit, fetchurl, ... }:
let
  rev = "c254d17c9b05363eff99c9e9baa529b2be779f4b";

  builtin-res = fetchurl {
    url = "http://www.havenandhearth.com/java/builtin-res.jar";
    sha256 = "sha256-V+NvcusHy3RyK+iwMojWU5VtFrzkDbNAYvQFsVgyvWM=";
  };

  hafen-res = fetchurl {
    url = "http://www.havenandhearth.com/java/hafen-res.jar";
    sha256 = "sha256-OypMzB8TA307vz/h6H3E7Oe9U67+gsMdsbyjkXnHYiM=";
  };
in
stdenv.mkDerivation {
  pname = "haven-and-hearth";
  version = "g${rev}";

  src = fetchgit {
    url = "git://sh.seatribe.se/hafen-client";
    sha256 = "sha256-fIKu7zjDwhiepYO4n0Qx3MCqJDQa+ogZocKGlW1taMQ=";

    inherit rev;
  };

  nativeBuildInputs = [ jdk ant ];

  buildInputs = [
    javaPackages.jogl_2_3_2
  ];

  preConfigure = ''
    mkdir build
    cp ${builtin-res} build/builtin-res.jar
    cp ${hafen-res} build/hafen-res.jar
  '';

  buildPhase = "ant";

  installPhase = ''
    mkdir -p $out/{lib,bin}

    install build/*.jar $out/lib/

    cat <<EOF > $out/bin/haven
    #!/usr/bin/env bash
    jogl=${javaPackages.jogl_2_3_2}/share/java
    export CLASSPATH=$jogl/gluegen-rt-natives-linux-amd64.jar:jogl-all-natives-linux-amd64.jar:$CLASSPATH
    ${jdk}/bin/java -jar $out/lib/hafen.jar
    EOF
    chmod +x $out/bin/haven
  '';

  JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF8";
}
