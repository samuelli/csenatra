class CoreApp < Sinatra::Base
  configure do
    set :public_folder, File.join(RACK_ROOT, "public")
    set :views, File.join(RACK_ROOT, "views")
  end
  
  helpers do
    def protected!
      unless session[:user]
        redirect "/~maxs/auth"
      end
    end

    def link_active?(link)
      path = if ENV["RACK_ENV"] == 'development'
        env["REQUEST_PATH"]
      else
        env["REQUEST_URI"]
      end
      if path.gsub(/\/\~maxs/, "").gsub(/\/$/, '') == "#{link}"
        "active"
      else
        ""
      end
    end
  end
  
  before do
    @user = session[:user]
    @custom_body_id = 'bootstrap-body'
  end

end
