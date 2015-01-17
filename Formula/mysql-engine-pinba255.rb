require File.expand_path("../../Abstract/abstract-engine-pinba255", __FILE__)

class MysqlEnginePinba255 < AbstractEnginePinba255
  init

  depends_on 'mysql'

  conflicts_with 'percona-engine-pinba', 'percona-engine-pinba255', 'mysql-engine-pinba',
    :because => "It installs the same binaries."

  resource "mysql" do
    url "http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.22.tar.gz"
    sha1 "31ac6f799dd76950b4de9979320129ac04fb38e1"
  end

  resource "master" do
    url 'https://github.com/tony2001/pinba_engine/archive/master.tar.gz'
    sha1 '07f5640339e96487630b0617a7283b6f28c7697c'
  end

  def install
    resource("mysql").stage do
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
    else
      # Configure with protobuf
      args << "--with-protobuf=#{Formula['protobuf'].opt_prefix}"
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
