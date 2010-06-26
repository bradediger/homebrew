require 'formula'

class Offlineimap < Formula
  url 'http://github.com/downloads/rue/offlineimap/offlineimap-6.2.0.tar.gz'
  homepage 'http://wiki.github.com/jgoerzen/offlineimap/'
  md5 '919ad6f71b8437ad0a08a5fdeae9cb67'

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
