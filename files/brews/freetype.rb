require 'formula'

class Freetypephp < Formula
  homepage 'http://www.freetype.org'
  url 'http://downloads.sf.net/project/freetype/freetype2/2.4.11/freetype-2.4.11.tar.gz'
  sha256 '29a70e55863e4b697f6d9f3ddc405a88b83a317e3c8fd9c09dc4e4c8b5f9ec3e'

  keg_only "Sandboxed for PHP installations"

  option :universal

  bottle do
    # Included with X11 so no bottle needed before Mountain Lion.
    sha256 'TODO_Figure_this_out' => :mountain_lion
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end

  test do
    system "#{bin}/freetype-config", '--cflags', '--libs', '--ftversion',
      '--exec-prefix', '--prefix'
  end
end
