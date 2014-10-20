require File.expand_path("../../../../../Taps/homebrew/homebrew-php/Abstract/abstract-php-extension", __FILE__)

class Php56Pinba < AbstractPhp56Extension
  init
  homepage 'https://github.com/tony2001/pinba_extension'
  url 'https://github.com/tony2001/pinba_extension/archive/master.tar.gz'
  sha1 '063f1005f4d49a99d40c210476978acfa6d21b74'
  version 'rev-4f20a81a0c'
  head 'https://github.com/tony2001/pinba_extension.git'

  depends_on 'pinba'

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig
    system "make"
    prefix.install "modules/pinba.so"
    write_config_file if build.with? "config-file"
  end
end
