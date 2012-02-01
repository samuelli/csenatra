#!/usr/bin/env ruby
require './app'

Rack::Handler::CGI.run App.new
