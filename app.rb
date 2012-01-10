require 'rubygems'
require 'json'
require 'restclient'
require 'digest/sha1'
Dir["lib/*.rb"].each {|file| require file }

addon_name = 'heroku'
addon_config = ['HEROKU_URL', 'HEROKU_VAR1', 'HEROKU_VAR2']
sso_salt = "0hsvrk6MMZH9xZnK"
host = 'http://localhost:4567'
callback_url = 'http://localhost:9990'
customer_id = 'heroku_id'
user = 'myaddon'
password = 'NVUQ1OqNtuc74HiE'
bad_user = 'bad_user'
bad_password = 'bad_pass'

addon = Rest.new(host, user, password)
resp = nil

validate "Provisioning" do
  params = {}
  payload = { customer_id => user, 'plan' => 'free', 'callback_url' => callback_url, 'options' => '{}' }
  resp = addon.post("/heroku/resources", params, JSON.generate(payload))
  failed("response code: #{resp.code}") if resp.code != "200"
  passed
end

  if resp.code == "200"
  provision_info = nil
  validate "Valid JSON response" do
    begin
      provision_info = JSON.parse(resp.body)
    rescue Exception => e 
      failed e.message
    end
    passed
  end
  
  unless provision_info.nil?
    validate "Response params" do
      begin
        failed("Missing 'id'") if provision_info['id'].nil? || provision_info['id'] == ""
        failed("Missing 'config'") if provision_info['config'].nil?
      rescue Exception => e 
        failed e.message
      end
      passed
    end

    validate "All config keys are in manifest" do
      provision_info['config'].each do |key, value|
        unless addon_config.include? key; failed "#{key} not found in config"; end
      end
    end
    
    validate "All manifest config keys are in response" do
      addon_config.each do |key, value|
        unless provision_info['config'].include? key; failed "#{key} not found in manifest"; end
      end
    end
    
    validate "All config keys are prefixed with addon name" do
      config_prefix = "#{addon_name.upcase}_"
      provision_info['config'].each do |key, value|
        unless key.start_with? config_prefix; failed "#{key} does not begin with #{config_prefix}"; end
      end
      passed
    end

    resource_id = provision_info['id']
    unless resource_id.nil?
      validate "Update resource" do
        params = {}
        payload = { 'plan' => 'paid', 'callback_url' => callback_url, 'options' => '{}' }
        resp = addon.put("/heroku/resources/#{resource_id}", params, JSON.generate(payload))
        failed("response code: #{resp.code}") if resp.code != "200"
        passed
      end
      
      READLEN = 1024 * 10
      reader, writer = IO.pipe
      out = nil
      validate "Callback" do
        child = fork do
          reader.close
          server = TCPServer.open(9990)
          client = server.accept
          writer.write(client.readpartial(READLEN))
          client.write("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
          client.close
          writer.close
        end
        sleep(1)
        out = reader.readpartial(READLEN)
        passed
      end
  
      callback_info = nil    
      isValidCallback = false
      validate "Valid callback response" do
        _, json = out.split("\r\n\r\n")
        begin
          callback_info = JSON.parse(json)
        rescue Exception => e 
          failed e.message
        end
        isValidCallback = true
        passed
      end
      
      if isValidCallback
        validate "All callback config keys are in manifest" do
          callback_info['config'].each do |key, value|
            unless addon_config.include? key; failed "#{key} not found in config"; end
          end
        end

        validate "All callback manifest config keys are in response" do
          addon_config.each do |key, value|
            unless callback_info['config'].include? key; failed "#{key} not found in manifest"; end
          end
        end

        validate "All callback config keys are prefixed with addon name" do
          config_prefix = "#{addon_name.upcase}_"
          callback_info['config'].each do |key, value|
            unless key.start_with? config_prefix; failed "#{key} does not begin with #{config_prefix}"; end
          end
          passed
        end
      end
      
      validate "Single Sign On link" do
        timestamp = Time.now.to_i
        authstring = user.to_s + ':' + sso_salt + ':' + timestamp.to_s
        token = Digest::SHA1.hexdigest(authstring)
        resp = addon.get("/heroku/resources/#{resource_id}?token=#{token}&timestamp=#{timestamp}")
        passed unless resp.code != "200"
      end

      validate "Deprovision" do
        params = {}
        payload = { customer_id => user, 'plan' => 'free', 'callback_url' => callback_url, 'options' => '{}' }
        resp = addon.delete("/heroku/resources/#{resource_id}", params, JSON.generate(payload))
        failed("response code: #{resp.code}") if resp.code != "200"
        passed
      end
      
    end
  end

else
  failed
end

validate "Bad credentials test" do
  params = {}
  payload = { customer_id => user, 'plan' => 'free', 'callback_url' => callback_url, 'options' => '{}' }

  addon_bad_auth = Rest.new(host, bad_user, bad_password)
  resp = addon.post("/heroku/resources/", params, JSON.generate(payload))

  failed if resp.code == "200"
  passed
end
