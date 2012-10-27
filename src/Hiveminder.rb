require "rubygems"
require "bundler/setup"
require 'pry'
require 'typhoeus'
require 'oj'
require 'sequel'
require "sqlite3"


DB = Sequel.sqlite('hiveminder.db')

module Hiveminder
  def self.grab_comments
    DB.create_table? :comments do
      primary_key :id
      String :comment_id
      String :comment_text
      String :response_text
      Boolean :processed, :default => false
      Date :posted_response_on
    end
    saved_comments = DB[:comments]
    top_posts = Oj.load(Typhoeus::Request.get('http://www.reddit.com/.json').body)
    post_ids = top_posts["data"]["children"].map{|x| x["data"]["id"]}
    post_ids.each do |id|
      comments = Oj.load(Typhoeus::Request.get("http://www.reddit.com/comments/#{id}.json").body)
      text = comments.last["data"]["children"].first["data"]["body"].gsub(/[^\w ]/,"")
      name = comments.last["data"]["children"].first["data"]["name"]
      # next if db contains a processed row with name
      if saved_comments[:comment_id => name].nil?
          DB[:comments].insert(:comment_id => name, :comment_text => text)
      end
    end
  end
end

Hiveminder.grab_comments
