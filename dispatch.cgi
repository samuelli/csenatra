#!/usr/bin/env ruby
Dir[File.join(File::dirname(__FILE__), "cgi-bin/vendor/gems/**")].map do |dir|
  File.directory?(lib = "#{dir}/lib") ? lib : dir
end.each {|x| $LOAD_PATH << x}

require File.join(File::dirname(__FILE__), "cgi-bin",  "app")

rack_app = Rack::Builder.new do
  run App.new
end

Rack::Handler::CGI.run rack_app
