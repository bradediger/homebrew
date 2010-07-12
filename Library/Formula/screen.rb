require 'formula'

# [BE] Screen 4.0.3 goodness
class Screen < Formula
  url 'http://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz'
  homepage 'http://www.gnu.org/software/screen/'
  md5 '8506fd205028a96c741e4037de6e3c42'

  def install
    system "./configure", "--prefix=#{prefix}", "--enable-colors256"
    system "make install"
  end
end
