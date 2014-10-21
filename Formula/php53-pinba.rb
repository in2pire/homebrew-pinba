require File.expand_path("../../../../../Taps/homebrew/homebrew-php/Abstract/abstract-php-extension", __FILE__)

class Php53Pinba < AbstractPhp53Extension
  init
  homepage 'https://github.com/tony2001/pinba_extension'
  url 'https://github.com/tony2001/pinba_extension/archive/4f20a81a0c1d1e57f0f361d403e6610099df1ba0.tar.gz'
  sha1 '918edb29a7072cbd0a1feba7f86228be092d0dcb'
  version 'rev-4f20a81a0c'
  head 'https://github.com/tony2001/pinba_extension.git'

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
