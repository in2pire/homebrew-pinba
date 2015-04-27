require 'formula'

class AbstractEnginePinba255 < Formula
  def self.init
    homepage 'http://pinba.org'
    url 'https://github.com/in2pire/pinba_engine/releases/download/v1.1.0/pinba_engine-1.1.0.tar.gz'
    sha1 'e916ee961801f3755d663f0db13f144fc0c6fc63'
    head 'https://github.com/in2pire/pinba_engine.git'

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
