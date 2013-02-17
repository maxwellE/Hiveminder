require 'snoo'
require 'oj'
require 'typhoeus'

module Reddit
  def sign_in(username,password)
    @client = Snoo::Client.new
    @client.log_in username, password
  end
  
  def log_out
    @client.log_out
  end
  
  def get_new_comments
    @client.get_messages("unread",{:mark=>true})["data"]["children"]
  end
  
  def get_top_posts_ids(count) 
    top_posts = Oj.load(Typhoeus::Request.get('http://www.reddit.com/.json').body)
    top_posts["data"]["children"].map{|x| x["data"]["id"]}[0...count]
  end
  
  def grab_top_post_comment(post_id)
    comments = Oj.load(Typhoeus::Request.get("http://www.reddit.com/comments/#{post_id}.json").body)
    text = comments.last["data"]["children"].first["data"]["body"].gsub(/[^\w]|http[^ ]*/," ").strip.gsub(/  /," ").strip
    name = comments.last["data"]["children"].first["data"]["name"]
    return text,name
  end
  
  def perform_comment?(username,password,response,comment_id)
    begin
      @client.comment(response, comment_id)
      true
    rescue
      puts "Failed to comment"
      puts $@
      puts $!
      false
    end
  end
end
