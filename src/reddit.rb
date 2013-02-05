require 'snoo'

module Reddit
  def sign_in(username,password)
    @client = Snoo::Client.new
    @client.log_in username, password
  end
  
  def log_out
    @client.log_out
  end
  
  def get_comments
    reddit.get_messages("unread",{:mark=>true})["data"]["children"]
  end
  
  def get_top_posts(count) 
    
  end

end