require File.expand_path("../../Abstract/abstract-engine-pinba", __FILE__)

class PerconaEnginePinba < AbstractEnginePinba
  init

  depends_on 'percona-server'

  conflicts_with 'mysql-engine-pinba', 'mysql-engine-pinba-tagsize255', 'percona-engine-pinba-tagsize255',
    :because => "It installs the same binaries."

  resource "percona" do
    url 'https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-5.6.24-72.2/source/tarball/percona-server-5.6.24-72.2.tar.gz'
    sha1 '385813d75ee2962e82c2d51dfb263c8ca46bfe75'
  end

  resource "master" do
    url 'https://github.com/tony2001/pinba_engine/archive/master.tar.gz'
    sha1 '592eb7cc76044df448ad8cc5fbe3022ef908a75b'
  end

  # Fix https://github.com/tony2001/pinba_engine/issues/40
  patch :DATA

  def install
    resource("percona").stage do
      system "/usr/local/bin/cmake -DBUILD_CONFIG=mysql_release -Wno-dev && cd include && make"
      cp_r pwd, buildpath/"mysql"
    end

    resource("master").stage do
      cp_r "scripts", buildpath/"scripts"
    end

    args = ["--prefix=#{prefix}",
            "--libdir=#{prefix}/plugin",
            "--with-mysql=#{buildpath}/mysql",
            "--with-judy=#{Formula['judy'].opt_prefix}",
            "--with-event=#{Formula['libevent'].opt_prefix}"]

    if build.head?
      # Run buildconfig
      system "./buildconf.sh"
    end

    system "./configure", *args
    system "make"
    system "make install"

    # Install plugin
    plugin_dir = Formula['percona-server'].lib/"mysql/plugin";
    plugin_file = "#{plugin_dir}/libpinba_engine.so"
    system "if [ -L \"#{plugin_file}\" ]; then rm -f \"#{plugin_file}\"; fi"

    plugin_dir.install_symlink prefix/"plugin/libpinba_engine.so"
    system "cp -R \"#{buildpath}/default_tables.sql\" #{prefix}"
    system "cp -R \"#{buildpath}/scripts\" #{prefix}/"
  end
end

__END__
diff --git a/src/ha_pinba.cc b/src/ha_pinba.cc
index 8c71010..85193bb 100644
--- a/src/ha_pinba.cc
+++ b/src/ha_pinba.cc
@@ -2684,7 +2684,7 @@ int ha_pinba::read_next_row(unsigned char *buf, uint active_index, bool by_key)

 				str_hash = this_index[active_index].ival;

-				ppvalue = JudyLNext(D->tag.name_index, &str_hash, NULL);
+				ppvalue = JudyLNext(D->tag.name_index, (Word_t *)&str_hash, NULL);
 				if (!ppvalue) {
 					ret = HA_ERR_END_OF_FILE;
 					goto failure;
