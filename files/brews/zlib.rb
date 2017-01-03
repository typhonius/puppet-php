require 'formula'

class Zlibphp < Formula
  homepage 'http://www.zlib.net/'
  url 'http://zlib.net/zlib-1.2.10.tar.gz'
  sha256 '8d7e9f698ce48787b6e1c67e6bff79e487303e66077e25cb9784ac8835978017'

  keg_only :provided_by_osx

  version '1.2.8-boxen1'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
