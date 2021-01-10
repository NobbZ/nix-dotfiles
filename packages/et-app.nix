{ mkYarnPackage, fetchFromGitLab, ... }:

mkYarnPackage rec {
  pname = "etwin-app";
  version = "0.4.2";

  src = fetchFromGitLab {
    name = "${pname}-source";
    owner = "eternal-twin";
    repo = pname;
    rev = "951726615363c52ac3dc3f5dbc92670bcc80be5c";
    sha256 = "sha256-BOcV+o1wOzSXnyPz/r2GmJValZR7jz0qveWuQXurV4Q=";
  };

  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";
}
