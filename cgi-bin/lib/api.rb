class ApiApp < CoreApp
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      env["REMOTE_USER"] == "maxs"
    end

    def get_files
      `ls #{File.join(File.dirname(__FILE__), 'uploads')}`.split("\n")
    end
  end
  
  before do
    protected!
  end
  
  # You can upload a file to be printed
  post '/upload_print' do
    content_type :json

    # TODO: this
    [false].to_json
  end

  # You can see a list of files available to be printed.
  # This _was_ going to be a database, but then `scp` woudln't
  # work.
  get '/print_queue' do
    content_type :json

    get_files.to_json
  end

  get '/print' do
    content_type :json

    if get_files.include?(params[:file])
      # status = `lpr -P #{params[:file]}`
      # {:status => status}.to_json
    else
      halt 400, "FILE_MISSING"
    end
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
      result = `pp \`priv upi "#{user}"\``
    else
      result = `pp "#{user}"`
    end
    if result == ""
      nil # not found
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
        if result[field]
          # Make it an array! One element for each line
          if result[field].class == Array
            result[field] << value
          else
            result[field] = [result[field], value]
          end
        else
          # Set from nil to a value
          result[field] = value
        end
      end
    end
    return result
  end

end
