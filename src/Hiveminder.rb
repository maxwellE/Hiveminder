#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require 'pry'
require_relative 'db_manager'
require_relative 'reddit'
require_relative 'pandorabots'

module Hiveminder
  extend Pandorabots
  extend Reddit
  extend DbManager
  def self.grab_comments(username, password)
    create_db_and_table?
    client = sign_in_and_get_client(username,password)
    comment_count = 0
    get_new_comments(client).each do |unread_comment|
      unless db_contains_comment?(unread_comment["data"]["name"])
        insert_response_comment(unread_comment["data"]["name"],unread_comment["data"]["body"])
        comment_count +=1
      end
    end
    puts "!!!!   #{comment_count} response comment(s) added.   !!!!"
    log_out_client(client)
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
    puts "!!!! DONE WITH GRAB !!!!"
    client.clear_sessions password
  end

  def self.post_comments(username,password,api_secret,api_key)
    next_comment = get_next_response_or_post
    if next_comment
      pandorabot_response = next_comment[:response_text] || get_pandorabots_response(next_comment[:comment_text],754,api_secret,api_key)
      if pandorabot_response
        unless next_comment[:response_text]
          save_pandorabot_response(next_comment[:id],pandorabot_response)
        end
        if perform_comment?(username,password,pandorabot_response,next_comment[:comment_id])
          puts "Responsed to comment #{next_comment[:comment_text]} with #{pandorabot_response}"
          mark_comment_as_processed_in_db(next_comment[:id])
        end
      end
    end
    puts "DONE WITH POST"
  end
end

if $0 == __FILE__
  if ARGV[0] == "grab"
    puts "Grabbing posts"
    Hiveminder.grab_comments(ARGV[1], ARGV[2])
  elsif ARGV[0] == "post"
    puts "Posting comment"
    Hiveminder.post_comments(ARGV[1], ARGV[2], ARGV[3], ARGV[4])
  else
    puts "Invalid option provided, either use 'grab' or 'posts'."
  end
end
