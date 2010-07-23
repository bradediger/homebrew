require 'formula'

class Gibak < Formula
  head 'git://github.com/mfp/gibak.git'
  @specs = {:branch => 'master'}
  homepage 'http://eigenclass.org/hiki/gibak-0.3.0'

  depends_on 'o-make'
  depends_on 'objective-caml'
  depends_on 'objective-caml-findlib'
  depends_on 'objective-caml-fileutils'

  def install
    system "omake"
    # poor man's make install
    bin.install Dir['*']
  end
end
