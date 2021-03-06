require "formula"

class Mame < Formula
  homepage "http://mamedev.org/"
  url "https://github.com/mamedev/mame/archive/mame0156.tar.gz"
  sha1 "9cda662385c0b168ca564dab0fb1e839065f6a01"
  version "0.156"

  head "https://github.com/mamedev/mame.git"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/games"
    cellar :any
    sha1 "a112d2ebeb55c84aecef3586a533dffd00a17a9a" => :yosemite
    sha1 "7ec476401fd96219db0f0f18783a8f96a56b1893" => :mavericks
    sha1 "8f8cb3da984b7e7955f75a17e54de9ba9ab2d264" => :mountain_lion
  end

  depends_on "sdl2"

  # Fix build with non-framework SDL 2 issue on OS X.
  # Linking Cocoa's library. Don't hard coding SDL execution name.
  # Upstream: <https://github.com/mamedev/mame/pull/60>
  patch :DATA

  def install
    ENV["MACOSX_USE_LIBSDL"] = "1"
    ENV["PTR64"] = (MacOS.prefer_64_bit? ? "1" : "0")
    ENV["LTO"] = "1" if ENV.compiler == :clang or ENV.compiler =~ /^gcc-(4\.[6-9])$/

    system "make", "CC=#{ENV.cc}", "LD=#{ENV.cxx}",
                   "TARGET=mame", "SUBTARGET=mame"

    if MacOS.prefer_64_bit?
      bin.install "mame64" => "mame"
    else
      bin.install "mame"
    end
  end
end

__END__
diff --git a/src/osd/sdl/sdl.mak b/src/osd/sdl/sdl.mak
index 21dd814..eaec664 100644
--- a/src/osd/sdl/sdl.mak
+++ b/src/osd/sdl/sdl.mak
@@ -507,8 +507,8 @@ else
 # files (header files are #include "SDL/something.h", so the extra "/SDL"
 # causes a significant problem)
-INCPATH += `sdl-config --cflags | sed 's:/SDL::'`
+INCPATH += `$(SDL_CONFIG) --cflags | sed 's:/SDL::'`
 CCOMFLAGS += -DNO_SDL_GLEXT
 # Remove libSDLmain, as its symbols conflict with SDLMain_tmpl.m
-LIBS += `sdl-config --libs | sed 's/-lSDLmain//'` -lpthread -framework OpenGL
+LIBS += `$(SDL_CONFIG) --libs | sed 's/-lSDLmain//'` -lpthread -framework Cocoa -framework OpenGL
 DEFS += -DMACOSX_USE_LIBSDL
 endif   # MACOSX_USE_LIBSDL
