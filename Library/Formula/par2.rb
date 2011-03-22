require 'formula'

class Par2 < Formula
  url 'http://downloads.sourceforge.net/project/parchive/par2cmdline/0.4/par2cmdline-0.4.tar.gz'
  homepage 'http://parchive.sourceforge.net/'
  sha1 '2fcdc932b5d7b4b1c68c4a4ca855ca913d464d2f'

  def patches
    # gist: Debian's 003_fix_crash_in_quiet_mode.patch
    %w[http://sage.math.washington.edu/home/binegar/src/par2cmdline-0.4-gcc4.patch
    https://gist.github.com/raw/784811/83a1bb2d8283e269ae6e93355eaa68579f0272fd/gistfile1.diff]
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
