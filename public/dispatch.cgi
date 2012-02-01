#!/usr/bin/env ruby

Dir[File.join(File::dirname(__FILE__), "./vendor/gems/**")].map do |dir|
  File.directory?(lib = "#{dir}/lib") ? lib : dir
end.each {|x| $LOAD_PATH << x}

require File.join(File::dirname(__FILE__), "..", "app")

Rack::Handler::CGI.run App.new
