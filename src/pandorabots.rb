require 'json'
module Pandorabots
  def get_pandorabots_response(comment_text,bot_id,api_secret,api_key)
    begin
      response = `/usr/bin/php /home/ec2-user/Hiveminder/src/api_request.php abc-#{Time.now.to_i.to_s[0..8]} '#{comment_text}' #{api_key} #{api_secret} #{bot_id}`
      response =~ /\)<br>(.+)\z/
      return JSON.load($1)["message"]["message"]
    rescue
      return nil
    end
  end
end
