require "rubygems"
require "bundler/setup"
require 'pry'
require 'typhoeus'
require 'oj'


module Hiveminder
  def self.grab_comments
    top_posts = Oj.load(Typhoeus::Request.get('http://www.reddit.com/.json').body)
    post_ids = top_posts["data"]["children"].map{|x| x["data"]["id"]}
    post_ids.each do |id|
      comments = Oj.load(Typhoeus::Request.get("http://www.reddit.com/comments/#{id}.json").body)
      text = comments.last["data"]["children"].first["data"]["body"].gsub(/[^\w ]/,"")
      name = comments.last["data"]["children"].first["data"]["name"]
      # next if db contains a processed row with name
      
      binding.pry
    end
  end
end

Hiveminder.grab_comments