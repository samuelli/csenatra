# CSEnatra - Remote Version

This is a working Sinatra app that can run on CSE
servers. It also exposes some functionality via
a JSON api. There is an [iOS App](https://github.com/maxpow4h/k17_ios)
that will allow you to use this remotely.

## Remote Version

This branch is the 'remote version' which features only the
minimum to provie a backend for the iOS App K17 or bark.
This can run along side other web apps inside your `public_html`.

## Install

Put this inside your `public_html` in an `api` directory.
Consider forking this repo and then
`git clone git://github.com/maxpow4h/csenatra api`

- You will have to replace all occurrences `~samli` with your username.
- Run `bundle install --deployment` to make a `Gemfile.lock` file.
- Also check the file permissions are correct (they will need fiddling with).
- If something is going wrong for you, enable debugging in the `.htaccess` file