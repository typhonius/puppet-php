require 'formula'

class Zlibphp < Formula
  homepage 'http://www.zlib.net/'
  url 'http://zlib.net/zlib-1.2.8.tar.gz'
  sha256 '36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d'

  keg_only :provided_by_osx

  version '1.2.8-boxen1'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
