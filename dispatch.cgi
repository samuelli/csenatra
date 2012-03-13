#!/web/stulocal/bin/ruby1.8.7

ENV['BUNDLE_GEMFILE'] = '/web/samli/cgi-bin/Gemfile'
ENV['RACK_ENV']       = 'production'

$LOAD_PATH << '/web/stulocal/lib/ruby/gems/1.8/gems/bundler-1.0.15/lib'
require File.join(File::dirname(__FILE__), "cgi-bin", "app")

Rack::Handler::CGI.run App
