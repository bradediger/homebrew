require 'formula'

class ObjectiveCamlFileutils < Formula
  head 'http://le-gall.net/sylvain+violaine/download/ocaml-fileutils-latest.tar.gz'
  homepage 'http://le-gall.net/sylvain+violaine/ocaml-fileutils.html'
  md5 '93437c0fe6fa0e02c30e87af6a0d4e14'

  depends_on 'objective-caml'
  depends_on 'objective-caml-findlib'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end

end
