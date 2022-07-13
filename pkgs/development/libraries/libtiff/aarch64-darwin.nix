{ lib, stdenv
, fetchurl

, pkg-config
, cmake

, libdeflate
, libjpeg
, xz
, zlib
}:

stdenv.mkDerivation rec {
  pname = "libtiff";
  version = "4.4.0";

  src = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    sha256 = "sha256-kXIjs3U4lZrKO3kNLXOqbmJraI4C3NonKuwkwvSYq+0=";
  };

  cmakeFlags = lib.optional stdenv.isDarwin "-DCMAKE_SKIP_BUILD_RPATH=OFF";

  # FreeImage needs this patch
  patches = [ ./headers-cmake.patch ];

  outputs = [ "bin" "dev" "dev_private" "out" "man" "doc" ];

  postFixup = ''
    moveToOutput include/tif_dir.h $dev_private
    moveToOutput include/tif_config.h $dev_private
    moveToOutput include/tiffiop.h $dev_private
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  propagatedBuildInputs = [ libjpeg xz zlib ]; #TODO: opengl support (bogus configure detection)

  buildInputs = [ libdeflate ]; # TODO: move all propagatedBuildInputs to buildInputs.

  enableParallelBuilding = true;

  doInstallCheck = true;
  installCheckTarget = "test";

  meta = with lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = "https://libtiff.gitlab.io/libtiff";
    changelog = "https://libtiff.gitlab.io/libtiff/v${version}.html";
    license = licenses.libtiff;
    platforms = platforms.unix;
  };
}
