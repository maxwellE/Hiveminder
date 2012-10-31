#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require 'pry'
require 'oj'
require 'sequel'
require "sqlite3"
require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'snoo'
require 'typhoeus'


REDDIT_USERNAME = "I_AM_TEH_HIVEMIND"
REDDIT_PASSWORD = "sweetpea"

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

  def self.post_comments
    posts = DB[:comments]
    uncommented_posts = posts.where(:processed => false)
    if uncommented_posts.all.size > 0
      reddit = Snoo::Client.new
      reddit.log_in REDDIT_USERNAME, REDDIT_PASSWORD
      comment_post = uncommented_posts.first
      noko_res = Nokogiri::XML(Net::HTTP.post_form(URI('http://www.pandorabots.com/pandora/talk-xml'),'botid'=>'b63f3ee30e34cbdd','input'=>comment_post[:comment_text]).body)
      response = noko_res.search('that').first.content
      comment_res = reddit.comment(response, comment_post[:comment_id])
      unless comment_res["jquery"][10].last.first =~ /RATELIMIT/
        posts.where('id = ?',comment_post[:id]).update(:processed => true,:response_text => response, :posted_response_on => Date.today)
      end
    end
  end
end

if $0 == __FILE__
  if ARGV[0] == "grab"
    puts "Grabbing posts"
    Hiveminder.grab_comments
  elsif ARGV[0] == "post"
    puts "Posting comment"
    Hiveminder.post_comments
  end
end
