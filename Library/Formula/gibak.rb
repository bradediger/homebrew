require 'formula'

class Gibak < Formula
  head 'git://github.com/mfp/gibak.git'
  @specs = {:branch => 'master'}
  homepage 'http://eigenclass.org/hiki/gibak-0.3.0'

  depends_on 'o-make'
  depends_on 'objective-caml'
  depends_on 'objective-caml-findlib'
  depends_on 'objective-caml-fileutils'

  def patches
    DATA
  end

  def install
    system "omake"
    # poor man's make install
    bin.install Dir['*']
  end
end

# [BE] Don't rsync git repos into .git... it rarely gains us anything, and
# wastes a lot of space
__END__
diff --git a/gibak b/gibak
index 7f63f41..a98209e 100755
--- a/gibak
+++ b/gibak
@@ -81,8 +81,6 @@ function __handle_git_repositories() {
     mkdir -p "$base"
     find-git-repos -i -z | while read -d $'\0' rep; do
 	echo "  submodule $rep" >&2
-	rsync -a -F --relative --delete-excluded --delete-after \
-	    "$rep" "$base"
 	printf '[submodule "%s"]\n\tpath = %s\n\turl= %s\n' \
 	    "$rep" "$rep" "$base/$rep/.git" >> .gitmodules
     done

