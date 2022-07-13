{ fetchFromGitHub, stdenv, lib
, cmake, libGLU, libGL
, freetype, freeimage, zziplib, xorgproto, libXrandr
, libXaw, freeglut, libXt, libpng, boost, ois
, libX11, libXmu, libSM, pkg-config
, libXxf86vm, libICE
, libXrender, zlib, pugixml
, Foundation, Cocoa
, writeScriptBin
, withNvidiaCg ? false, nvidia_cg_toolkit
, withSamples ? false }:

stdenv.mkDerivation rec {
  pname = "ogre";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "OGRECave";
    repo = "ogre";
    rev = "v${version}";
    sha256 = "sha256-H0LDFbXSqy40cwilCscSs3gKG+aXiXB84hcTqN4B7X4=";
  };

  cmakeFlags = [ 
    "-DOGRE_BUILD_DEPENDENCIES=OFF" 
    "-DOGRE_BUILD_SAMPLES=${toString withSamples}"
  ]
  ++ map (x: "-DOGRE_BUILD_PLUGIN_${x}=on")
           ([ "BSP" "OCTREE" "PCZ" "PFX" ] ++ lib.optional withNvidiaCg "CG")
  ++ map (x: "-DOGRE_BUILD_RENDERSYSTEM_${x}=on") [ "GL" ];

  nativeBuildInputs = [
    cmake
    # pkg-config
  ]
  ++ lib.optionals stdenv.isDarwin [
    # ditto binary from macOS required somewhere in ogre build scripts
    # but available only as binary /usr/bin/ditto outside build environment
    # so we have to use this hack to propogate /usr/bin/ditto to build environment
    # https://discourse.nixos.org/t/need-some-help-with-nix-for-macos/1151
    (writeScriptBin "ditto" ''
      #!${stdenv.shell}
      /usr/bin/ditto "$@"
    '')
  ];
  buildInputs = [
    freetype
    freeimage
    zziplib
  ]
  ++ lib.optionals stdenv.isDarwin [
    Foundation
    Cocoa
    pugixml   # required? cannot build without it on macos
  ];

  meta = {
    description = "A 3D engine";
    homepage = "https://www.ogre3d.org/";
    maintainers = [ lib.maintainers.raskin ];
    # platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
