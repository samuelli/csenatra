#!/usr/bin/env ruby
require File.join(File::dirname(__FILE__), "..", "app.rb")

Rack::Handler::CGI.run App.new
