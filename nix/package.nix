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
  version = "2.27";
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

  meta = {
    description = "Less input preprocessor with explicit colorizer path support";
    homepage = "https://github.com/matoi/lesspipe";
    license = lib.licenses.gpl2Plus;
    mainProgram = "lesspipe.sh";
    platforms = lib.platforms.unix;
  };
}
