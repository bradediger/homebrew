require 'formula'

# [BE] Screen 4.0.3 goodness
class Screen < Formula
  url 'http://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz'
  homepage 'http://www.gnu.org/software/screen/'
  md5 '8506fd205028a96c741e4037de6e3c42'

  # Apple's patches to screen:
  # http://www.opensource.apple.com/source/screen/screen-12/patches/
  def patches
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}",
      "--enable-colors256"
    system "make install"
  end
end

__END__
diff --git a/Makefile.in b/Makefile.in
index db683ac..14ba5db 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -79,7 +79,7 @@ install_bin: .version screen
 	-if [ -f $(DESTDIR)$(bindir)/screen ] && [ ! -f $(DESTDIR)$(bindir)/screen.old ]; then mv $(DESTDIR)$(bindir)/screen $(DESTDIR)$(bindir)/screen.old; fi
 	rm -f $(DESTDIR)$(bindir)/screen
 	(cd $(DESTDIR)$(bindir) && ln -sf $(SCREEN) screen)
-	cp $(srcdir)/utf8encodings/?? $(DESTDIR)$(SCREENENCODINGS)
+	cp $(srcdir)/utf8encodings/?? $(DSTROOT)$(SCREENENCODINGS)
 
 ###############################################################################
 install: installdirs install_bin
@@ -95,7 +95,7 @@ install: installdirs install_bin
 
 installdirs:
 # Path leading to ETCSCREENRC and Socketdirectory not checked.
-	$(srcdir)/etc/mkinstalldirs $(DESTDIR)$(bindir) $(DESTDIR)$(SCREENENCODINGS)
+	$(srcdir)/etc/mkinstalldirs $(DESTDIR)$(bindir) $(DSTROOT)$(SCREENENCODINGS)
 	cd doc ; $(MAKE) installdirs
 
 uninstall: .version
@@ -122,7 +122,7 @@ tty.c:	tty.sh
 	sh $(srcdir)/tty.sh tty.c
 
 comm.h: comm.c comm.sh config.h
-	AWK=$(AWK) CC="$(CC) $(CFLAGS)" srcdir=${srcdir} sh $(srcdir)/comm.sh
+	AWK=$(AWK) srcdir=${srcdir} sh $(srcdir)/comm.sh
 
 osdef.h: osdef.sh config.h osdef.h.in
 	CPP="$(CPP) $(CPPFLAGS)" srcdir=${srcdir} sh $(srcdir)/osdef.sh
diff --git a/config.h.in b/config.h.in
index 4327855..a32d66b 100644
--- a/config.h.in
+++ b/config.h.in
@@ -208,14 +208,14 @@
  * If screen is installed with permissions to update /etc/utmp (such
  * as if it is installed set-uid root), define UTMPOK.
  */
-#define UTMPOK
+#undef UTMPOK
 
 /* Set LOGINDEFAULT to one (1)
  * if you want entries added to /etc/utmp by default, else set it to
  * zero (0).
  * LOGINDEFAULT will be one (1) whenever LOGOUTOK is undefined!
  */
-#define LOGINDEFAULT	1
+#undef LOGINDEFAULT
 
 /* Set LOGOUTOK to one (1)
  * if you want the user to be able to log her/his windows out.
@@ -231,7 +231,7 @@
  * Set CAREFULUTMP to one (1) if you want that users have at least one
  * window per screen session logged in.
  */
-#define LOGOUTOK 1
+#undef LOGOUTOK
 #undef CAREFULUTMP
 
 
diff --git a/configure b/configure
index 75675fc..c9dcbd3 100755
--- a/configure
+++ b/configure
@@ -5572,7 +5572,7 @@ cat >>conftest.$ac_ext <<_ACEOF
 
 #include <time.h> /* to get time_t on SCO */
 #include <sys/types.h>
-#if defined(SVR4) && !defined(DGUX)
+#if (defined(SVR4) || defined(__APPLE__)) && !defined(DGUX)
 #include <utmpx.h>
 #define utmp utmpx
 #else
@@ -5581,6 +5581,10 @@ cat >>conftest.$ac_ext <<_ACEOF
 #ifdef __hpux
 #define pututline _pututline
 #endif
+#ifdef __APPLE__
+#define pututline pututxline
+#define getutent getutxent
+#endif
 
 int
 main ()
diff --git a/pty.c b/pty.c
index f89d44c..38e9709 100644
--- a/pty.c
+++ b/pty.c
@@ -34,7 +34,7 @@
 #endif
 
 /* for solaris 2.1, Unixware (SVR4.2) and possibly others */
-#ifdef HAVE_SVR4_PTYS
+#if defined(HAVE_SVR4_PTYS) && !defined(__APPLE__)
 # include <sys/stropts.h>
 #endif
 
diff --git a/screen.c b/screen.c
index 70741df..5b6e74b 100644
--- a/screen.c
+++ b/screen.c
@@ -101,6 +101,10 @@
 
 #include "logfile.h"	/* islogfile, logfflush */
 
+#ifdef __APPLE__
+#include <vproc.h>
+#endif
+
 #ifdef DEBUG
 FILE *dfp;
 #endif
@@ -1211,6 +1216,11 @@ char **av;
   freopen("/dev/null", "w", stderr);
   debug("-- screen.back debug started\n");
 
+#ifdef __APPLE__
+	if (_vprocmgr_move_subset_to_user(real_uid, "Background") != NULL)
+		errx(1, "can't migrate to background session");
+#endif
+
   /* 
    * This guarantees that the session owner is listed, even when we
    * start detached. From now on we should not refer to 'LoginName'
diff --git a/window.c b/window.c
index 3b60ae0..5cae839 100644
--- a/window.c
+++ b/window.c
@@ -25,6 +25,7 @@
 #include <sys/stat.h>
 #include <signal.h>
 #include <fcntl.h>
+#include <unistd.h>
 #ifndef sun
 # include <sys/ioctl.h>
 #endif
@@ -1387,6 +1388,38 @@ char **args, *ttyn;
   return pid;
 }
 
+#ifdef RUN_LOGIN
+/*
+ * All of the logic to maintain utmpx is now built into /usr/bin/login, so
+ * all we need to do is call it, and pass the shell command to it.
+ */
+extern char *LoginName;
+
+static int
+run_login(const char *path, char *const argv[], char *const envp[])
+{
+  const char *shargs[MAXARGS + 1 + 3];
+  const char **fp, **tp;
+
+  if (access(path, X_OK) < 0)
+    return -1;
+  shargs[0] = "login";
+  shargs[1] = (*argv[0] == '-') ? "-pfq" : "-pflq";
+  shargs[2] = LoginName;
+  shargs[3] = path;
+  fp = (const char **)argv + 1;
+  tp = shargs + 4;
+  /* argv has already been check for length */
+  while ((*tp++ = *fp++) != NULL) {}
+  /* shouldn't return unless there was an error */
+  return (execve("/usr/bin/login", (char *const*)shargs, envp));
+}
+
+/* replace the following occurrences of execve() with run_login() */
+#define execve run_login
+
+#endif /* RUN_LOGIN */
+
 void
 execvpe(prog, args, env)
 char *prog, **args, **env;

