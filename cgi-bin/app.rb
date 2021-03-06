require 'bundler'
Bundler.setup(:default, ENV["RACK_ENV"])
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
RACK_ROOT = File.dirname(__FILE__)
require 'sinatra' unless defined?(Sinatra)
require 'json'

class ApiApp < Sinatra::Base
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      # TODO: Abstract this to get it from ENV (or use the file path) for the admin user

      env["REMOTE_USER"] == "samli"
    end
  end
  
  before do
    protected!
  end

  get '/remote' do
    content_type :json

    if params['user']
      # lookup user details
      Remote::find_user(params['user'].gsub(/\"/, ''))

    elsif params['finger']
      # finger user
      Remote::finger_user(params['finger'].gsub(/\"/, '') )

    else
      halt 400, "INVALID_ACTION"
    end
  end
end

module Remote
  # Given a cse username or a student number
  def self.find_user(user)
    if user.match(/([\d]*)/)[1] == user
      cse_id = `priv upi "#{user}"`
      if cse_id != ""
        result = `pp #{cse_id}`
      else
        result = ""
      end
    else
      result = `pp "#{user}"`
    end
    if result == ""
      {:not_found => true}.to_json # not found
    else
      parse_user(result).to_json
    end
  end

  # Given a string to finger, finger it.
  def self.finger_user(finger)
    output = `finger "#{finger}"`
    results = []
    output.each_line do |line|
      if (line[0..2] == "   " && line[3..10] != "Username")
        components = line.match(/   ([\w|-]*) (.*)$/)
        if components && components[1] && components[2]
          name = components[1]
          details = components[2].strip
          results << {:name => name, :details => details}
        end
      end
    end

    results.to_json
  end

  # Parse User
  def self.parse_user(user)
    fields = {"User Name" => :user,
      "Uid" => :uid,
      "Aliases" => :aliases,
      "Groups" => :groups,
      "Expires" => :expires,
      "User classes" => :classes,
      "Group Classes" => :groups,
      "Name" => :name,
      "Printer Usage Status" => :printer,
      "Daily IP Quota" => :daily_quota,
      "Session IP Quota" => :session_quota,
      "Session IP Usage" => :session_usage}

    result = {}
    key = nil
    user.each_line do |line|
      l = line.match(/\s*([^:]*) : (.*)[\s]*$/)
      # Skip empty lines
      next if l.nil?
      key = l[1] if l[1] != ""
      value = l[2]
      field = fields[key]
      # If its a key I have
      if field
        
        # This if is for if the key was defined in a previous line.
        # Then it should recycle the key.
        # it should also make an array of values, since it is miltiline
        if result[field]
          # Make it an array! One element for each line
          if result[field].class == Array
            result[field] << value
          else
            result[field] = [result[field], value]
          end
          
          # The else is for if this is a new key, to define it and set it as a line
        else
          # Set from nil to a value
          result[field] = value
        end
      end
    end
    
    begin
      if result[:classes].class == Array
        result[:program] = result[:classes][0].match(/^(\d{4})_Student/)[1]
      else
        # Condition for single line classes
        result[:program] = result[:classes].match(/^(\d{4})_Student/)[1]
      end
    rescue
      result[:program] = "NONCSE"
    end
    result[:user] = result[:user].match(/^\S*/)[0]
    
    return result
  end

end

App = Rack::Builder.new do
  # This only occurs on local machine, since the rewrite removes it.
  map '/' do
    run ApiApp 
  end
end
