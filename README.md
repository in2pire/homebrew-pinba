# Homebrew-Pinba

A repository for [Pinba](http://pinba.org)-related brews.

## Requirements

* [Homebrew](https://github.com/Homebrew/homebrew)
* [Homebrew-PHP](https://github.com/Homebrew/homebrew-php) (Optional, for phpXY-pinba brews)
* Snow Leopard, Lion, Mountain Lion, Mavericks. Untested everywhere else.

## Installation

Run the following in your terimnal:

```sh
brew tap in2pire/pinba
```

Then if you are using mysql, run:

```sh
brew install mysql-engine-pinba
```

Or if you are using percona-server, run:

```sh
brew install percona-engine-pinba
```

After installing pinba engine, you need to install the plugin and default tables:

```sh
mysql -e "INSTALL PLUGIN pinba SONAME 'libpinba_engine.so';"
mysql -e "CREATE DATABASE pinba;"
# If you are using percona-server
mysql -D pinba < /usr/local/opt/percona-engine-pinba/default_tables.sql
# If you are using mysql
mysql -D pinba < /usr/local/opt/mysql-engine-pinba/default_tables.sql
```

Optional: If you need PHP extension, run:

```sh
brew install phpXY-pinba
```

with XY is your PHP version (see homebrew/php), don't forget to edit ext-pinba.ini to enable and set pinba server. After that, restart your web server.

## Todo

- [ ] Create mariadb-engine-pinba for mariadb

## License

Do anything you want :)
