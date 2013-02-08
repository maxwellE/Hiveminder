#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require 'pry'

require 'nokogiri'
require 'net/http'
require 'open-uri'
require_relative 'db_manager'
require_relative 'reddit'

module Hiveminder
  extend Reddit
  extend DbManager
  def self.grab_comments(username, password)
    create_db_and_table?
    sign_in(username,password)
    comment_count = 0
    get_new_comments.each do |unread_comment|
      unless db_contains_comment?(unread_comment["data"]["name"])
        insert_response_comment(unread_comment["data"]["name"],unread_comment["data"]["body"])
        comment_count +=1
      end
    end
    puts "!!!!   #{comment_count} response comment(s) added.   !!!!"
    log_out
    comment_count = 0
    get_top_posts_ids(5).each do |post_id|
      comment_text,comment_id = grab_top_post_comment(post_id)
      # next if db contains a processed row with name
      unless db_contains_comment?(comment_id)
        comment_count +=1
        insert_post_comment(comment_id,comment_text)
      end
    end
    puts "!!!!   #{comment_count} top post comment(s) added.   !!!!"
  end

  def self.post_comments(username,password)
    posts = DB[:comments]
    uncommented_posts = posts.where(:processed => false)
    if uncommented_posts.all.size > 0
      reddit = Snoo::Client.new
      reddit.log_in username, password
      comment_post = uncommented_posts.first
      noko_res = Nokogiri::XML(Net::HTTP.post_form(URI('http://www.pandorabots.com/pandora/talk-xml'),'botid'=>'b63f3ee30e34cbdd','input'=>comment_post[:comment_text]).body)
      response = noko_res.search('that').first.content
      comment_res = reddit.comment(response, comment_post[:comment_id])
      unless comment_res["jquery"][10].last.first =~ /RATELIMIT/
        posts.where('id = ?',comment_post[:id]).update(:processed => true,:response_text => response, :posted_response_on => Date.today)
      reddit.log_out
      end
    end
  end
end

if $0 == __FILE__
  if ARGV[0] == "grab"
    puts "Grabbing posts"
    Hiveminder.grab_comments(ARGV[1], ARGV[2])
  elsif ARGV[0] == "post"
    puts "Posting comment"
    Hiveminder.post_comments(ARGV[1], ARGV[2])
  else
    puts "Invalid option provided, either use 'grab' or 'posts'."
  end
end
