# CSEnatra

## File Permissions

The directories leading to the `app.rb` must be `chmod 751`.
`app.rb` can be `chmod 750`.


## Installing Gems On Server

1. Run `bundle install` to make a `Gemfile.lock` file.
2. `bundle package` will download all the `.gem` files into the
  `vendor/cache` directory.
3. Now go to the server and run 
  `gem install --no-ri --no-rdoc --install-dir vendor/ vendor/cache/*.gem`. 
  This will install the gems to `./vendor` so they can be loaded via the script.
