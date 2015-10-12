require File.expand_path("../../Abstract/abstract-engine-enhanced-pinba", __FILE__)

class PerconaEngineEnhancedPinba < AbstractEngineEnhancedPinba
  init

  depends_on 'percona-server'

  conflicts_with 'mysql-engine-pinba', 'mysql-engine-enhanced-pinba', 'percona-engine-pinba',
    :because => "It installs the same binaries."

  resource "percona" do
    url 'https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-5.6.25-73.1/source/tarball/percona-server-5.6.25-73.1.tar.gz'
    sha256 '5a0d88465e4bb081e621b06bc943fafadb4c67a2cca50839b44fcd94ae793b50'
  end

  resource "pinba-engine-6407919" do
    url 'https://github.com/in2pire/pinba_engine/archive/640791962dbc398e0bc00708bced1fd58c58b796.tar.gz'
    sha1 '733ad8e857531204ac2cc57aed3fb6ec0764e2c0'
  end

  # Fix https://github.com/tony2001/pinba_engine/issues/40
  patch :DATA

  def install
    resource("percona").stage do
      system "/usr/local/bin/cmake -DBUILD_CONFIG=mysql_release -Wno-dev && cd include && make"
      cp_r pwd, buildpath/"mysql"
    end

    resource("pinba-engine-6407919").stage do
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
