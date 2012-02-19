# CSEnatra

This is a working Sinatra app that can run on CSE
servers. It also exposes some functionality via
a JSON api. There is an [iOS App](https://github.com/maxpow4h/k17_ios)
that will allow you to use this remotely.

## Install

Take your `public_html` and rename it `old_public_html`.
`git clone git://github.com/maxpow4h/csenatra public_html`
to make this repo your new `public_html` (or consider forking
the repo and using your fork). Now copy the contents of your
`old_public_html` into `cgi-bin/public`.

You will have to replace `~maxs` with your username in the
following files

- `.htaccess`
- `cgi-bin/app.rb` in the `authorized?` method

Also, if you were using `php` or `cgi`, try using
[Rack Legacy](https://github.com/eric1234/rack-legacy).

## File Permissions

The directories leading to the `app.rb` must be `chmod 751`.
`app.rb` can be `chmod 750`.

Also the `.htaccess` file in `public` will need adjusting to match
the install.

## Installing Gems On Server

1. Run `bundle install --deployment` to make a `Gemfile.lock` file.
2. `bundle package` will download all the `.gem` files into the
  `vendor/cache` directory.

Also if you are using your own SQLite3, then the `bundle install` will
error. You then need to install the SQLite3 gem as per the instructions
with the added options of ` -- --with-sqlite3-dir=/home/maxs/lib/sqlite3`
or wherever your install is. E.g.

```sh
    gem install do_sqlite3 -v '0.10.8' --no-ri --no-rdoc
    --install-dir vendor/bundle/ruby/1.8/ -- --with-sqlite3-dir=/home/maxs/lib/sqlite3
```
