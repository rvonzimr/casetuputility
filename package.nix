{
  stdenv,
  unzip,
  autoPatchelfHook,
  fetchurl,
  qt5,
  libsForQt5,
  pkgs,
  patchelf,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "CASetupUtility";
  version = "v1.55";
  src = fetchurl {
    url = "https://ebikes.ca/pub/media/downloadable/CA_Setup_Utility_${finalAttrs.version}_Linux.zip";
    hash = "sha256-lRBhbNI8fnVW92se53dgR8y8ftUEGHM5XHfl55KvTmM=";
  };

  assets = ./assets;

  buildInputs = [
    qt5.qtbase
    libsForQt5.qtserialport
    makeWrapper
  ];
  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    unzip
    autoPatchelfHook
    patchelf
    pkgs.gcc
  ];

  preBuildPhase = ''
    cp -r ${finalAttrs.assets}/* ./;
  '';

  buildPhase = ''
    runHook preBuildPhase
    # Patch out the hardcoded config paths....
    ${pkgs.gcc}/bin/gcc -fPIC -shared chdir_wrapper.c -o ./chdir_wrapper.so -ldl
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/share/CASetupUtility $out/libexec

    cp CASetupUtility $out/libexec/
    cp ./chdir_wrapper.so $out/lib/
    cp -r data $out/share/CASetupUtility/
    cp ./light-theme.qss $out/share/CASetupUtility/light-theme.qss

    patchelf \
      --add-needed chdir_wrapper.so \
      $out/libexec/CASetupUtility

    substituteAll ./wrapper.sh $out/bin/CASetupUtility
    chmod +x $out/bin/CASetupUtility
  '';

})
