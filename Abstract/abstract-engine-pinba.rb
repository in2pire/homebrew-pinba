require 'formula'

class AbstractEnginePinba < Formula
  def self.init
    homepage 'http://pinba.org'
    url 'http://pinba.org/files/pinba_engine-1.1.0.tar.gz'
    sha1 'd0e20e6b1e15c5cbe90a84116c0bd7929c62a5e9'
    head 'https://github.com/tony2001/pinba_engine.git'

    depends_on 'pkg-config' => :build
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'cmake' => :build
    depends_on 'libtool' => :build

    depends_on 'protobuf'
    depends_on 'judy'
    depends_on 'libevent'

    # Fix https://github.com/tony2001/pinba_engine/issues/40
    patch :DATA
  end

  def caveats
    caveats = [""]

    caveats << <<-EOS
To finish installing Pinba engine:
  * in MySQL console execute:
  *
  *  mysql> INSTALL PLUGIN pinba SONAME 'libpinba_engine.so';
  *
  * Or create a separate database, this way:
  *
  *  mysql> CREATE DATABASE pinba;
  *
  * and then create the default tables:
  *
  * # mysql -D pinba < #{opt_prefix}/default_tables.sql

To uninstall Pinba engine, you need to do it manually :)

You can find useful scripts in #{opt_prefix}/scripts/

EOS

    caveats.join("\n")
  end
end

__END__
diff --git a/src/ha_pinba.cc b/src/ha_pinba.cc
index 8c71010..85193bb 100644
--- a/src/ha_pinba.cc
+++ b/src/ha_pinba.cc
@@ -2684,7 +2684,7 @@ int ha_pinba::read_next_row(unsigned char *buf, uint active_index, bool by_key)

         str_hash = this_index[active_index].ival;

-        ppvalue = JudyLNext(D->tag.name_index, &str_hash, NULL);
+        ppvalue = JudyLNext(D->tag.name_index, (Word_t *)&str_hash, NULL);
         if (!ppvalue) {
           ret = HA_ERR_END_OF_FILE;
           goto failure;
