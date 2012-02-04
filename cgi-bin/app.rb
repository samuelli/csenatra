# app.rb

require 'sinatra' unless defined?(Sinatra)
require File.join(File.dirname(__FILE__), 'remote')
require 'json'

class App < Sinatra::Base
  configure do
    set :public_folder, "#{File.dirname(__FILE__)}/public"
    set :views, "#{File.dirname(__FILE__)}/views"
  end

  helpers do

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      # The .htaccess will provide this
      env["REMOTE_USER"] == "maxs"
    end

    def get_files
      `ls #{File.join(File.dirname(__FILE__), 'uploads')}`.split("\n")
    end
  end

  get '/' do
    send_file File.join(settings.public_folder, "index.html")
  end

  # MAX ONLY PRIVATE AUTHED METHODS

  # You can upload a file to be printed
  post '/auth/upload_print' do
    protected!
    content_type :json

    # TODO: Printing Uploads via HTTP
    [false].to_json
  end

  # You can see a list of files available to be printed.
  # This _was_ going to be a database, but then `scp` woudln't
  # work.
  get '/auth/print_queue' do
    protected!
    content_type :json

    get_files.to_json
  end

  get '/auth/print' do
    protected!
    content_type :json

    if get_files.include?(params[:file])
      # TODO: Printing
      # status = `lpr -P #{params[:file]}`
      # {:status => status}.to_json
    else
      halt 400, "FILE_MISSING"
    end
  end

  get '/auth/remote' do
    protected!
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

  # PUBLIC ACCESS

  get '/auth' do
    @user = env["REMOTE_USER"]
    erb :auth
  end

end
