require File.expand_path("../../Abstract/abstract-engine-enhanced-pinba", __FILE__)

class MysqlEngineEnhancedPinba < AbstractEngineEnhancedPinba
  init

  depends_on 'mysql'

  conflicts_with 'percona-engine-pinba', 'percona-engine-enhanced-pinba', 'mysql-engine-pinba',
    :because => "It installs the same binaries."

  resource "mysql" do
    url "https://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.27.tar.gz"
    sha256 "8356bba23f3f6c0c2d4806110c41d1c4d6a4b9c50825e11c5be4bbee2b20b71d"
  end

  resource "pinba-engine-6407919" do
    url 'https://github.com/in2pire/pinba_engine/archive/640791962dbc398e0bc00708bced1fd58c58b796.tar.gz'
    sha256 '7cae3d2b3ee45bb0e8f364fe2c4bce072454c6c2179a907ea996d0b0d020ef77'
  end

  # Fix https://github.com/tony2001/pinba_engine/issues/40
  patch :DATA

  def install
    resource("mysql").stage do
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
    plugin_dir = Formula['mysql'].lib/"plugin";
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
