require 'formula'

class ObjectiveCamlFindlib < Formula
  url 'http://download.camlcity.org/download/findlib-1.2.5.tar.gz'
  homepage 'http://projects.camlcity.org/projects/findlib.html/'
  md5 'db12a92903c2869bb89e1a6446db269e'
  
  depends_on 'objective-caml'
  
  def install
    system "./configure"
    ENV.deparallelize
    system "make all"
    system "make opt"
    system "make install"
  end

end

