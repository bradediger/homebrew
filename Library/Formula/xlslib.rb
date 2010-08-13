require 'formula'

class Xlslib <Formula
  url 'http://downloads.sourceforge.net/project/xlslib/xlslib-1.6.0.zip'
  homepage 'http://xlslib.sourceforge.net/'
  md5 '357e670a43e111dcc3ad055e1cdc74b6'

  def install
    # xlslib ./configure will loop infinitely if run under /usr/local/bin/bash
    system "/bin/bash", "./configure", "--disable-debug", 
      "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
