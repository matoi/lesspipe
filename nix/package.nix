{
  bash,
  binutils,
  coreutils,
  file,
  gnugrep,
  gnused,
  gnutar,
  lib,
  libiconv,
  makeWrapper,
  ncurses,
  procps,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "lesspipe-plus";
  version = "2.27-plus.1";
  src = ../.;

  nativeBuildInputs = [ makeWrapper ];

  configureFlags = [
    "--shell=${bash}/bin/bash"
  ];

  postInstall = ''
    wrapProgram "$out/bin/lesspipe.sh" \
      --prefix PATH : ${
        lib.makeBinPath [
          binutils
          coreutils
          file
          gnugrep
          gnused
          gnutar
          libiconv
          ncurses
          procps
        ]
      }
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/lesspipe.sh" --version)" = \
      "lesspipe-plus 2.27-plus.1 (based on lesspipe 2.27)"
    runHook postInstallCheck
  '';

  meta = {
    description = "Less input preprocessor with explicit colorizer path support";
    homepage = "https://github.com/matoi/lesspipe";
    license = lib.licenses.gpl2Plus;
    mainProgram = "lesspipe.sh";
    platforms = lib.platforms.unix;
  };
}
