require File.expand_path("../../Abstract/abstract-engine-pinba", __FILE__)

class PerconaEnginePinba < AbstractEnginePinba
  init

  depends_on 'percona-server'

  conflicts_with 'mysql-engine-pinba', 'mysql-engine-enhanced-pinba', 'percona-engine-enhanced-pinba',
    :because => "It installs the same binaries."

  resource "percona" do
    url "https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.11-4/source/tarball/percona-server-5.7.11-4.tar.gz"
    sha256 "3634d2262e646db11b03837561acb0e084f33e5a597957506cf4c333ea811921"
  end

  resource "pinba-engine-5c72ed99" do
    url 'https://github.com/tony2001/pinba_engine/archive/5c72ed9956ba3a2f831ba19db2da26ee60fb246a.tar.gz'
    sha256 '5a1479438de10413a027bfb33ddb3e68e7c679e03138d7197cfd1c541c8e556c'
  end

  # Fix https://github.com/tony2001/pinba_engine/issues/40
  patch :DATA

  def install
    resource("percona").stage do
      system "/usr/local/bin/cmake -DBUILD_CONFIG=mysql_release -Wno-dev && cd include && make"
      cp_r pwd, buildpath/"mysql"
    end

    resource("pinba-engine-5c72ed99").stage do
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
