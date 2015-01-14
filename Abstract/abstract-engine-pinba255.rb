require 'formula'

class AbstractEnginePinba255 < Formula
  def self.init
    homepage 'http://pinba.org'
    url 'http://pinba.org/files/pinba_engine-1.0.0.tar.gz'
    head 'https://github.com/in2pire/pinba_engine.git'
    sha1 '8c456b20b4723bb403a585512c969d2053f45ba9'

    depends_on 'pkg-config' => :build
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'cmake' => :build
    depends_on 'libtool' => :build

    depends_on 'protobuf'
    depends_on 'judy'
    depends_on 'libevent'
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
