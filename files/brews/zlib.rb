require 'formula'

class Zlibphp < Formula
  homepage 'http://www.zlib.net/'
  url 'http://zlib.net/zlib-1.2.11.tar.xz'
  sha256 '4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066'

  keg_only :provided_by_osx

  version '1.2.11-boxen1'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
