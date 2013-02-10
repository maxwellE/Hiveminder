require 'sequel'
require "sqlite3"
DB = Sequel.sqlite('hiveminder_data.db')
module DbManager
  def create_db_and_table?
    DB.create_table? :comments do
      primary_key :id
      String :comment_id
      String :comment_text
      String :response_text
      Boolean :processed, :default => false
      Boolean :is_response, :default => false
      Date :posted_response_on
    end
  end
  def db_contains_comment?(comment_id)
    !(DB[:comments][:comment_id => comment_id]).nil?
  end
  
  def insert_response_comment(comment_id,comment_text)
     DB[:comments].insert(:comment_id=>comment_id, 
     :comment_text => comment_text,:is_response => true)
  end
  
  def insert_post_comment(comment_id,comment_text)
    DB[:comments].insert(:comment_id=>comment_id, 
     :comment_text => comment_text,:is_response => false)
  end
  
  def get_next_response_or_post
    DB[:comments][:processed => false, :is_response => true] || DB[:comments][:processed => false, :is_response => false]
  end
  
  def save_pandorabot_response(comment_id,response_text)
    DB[:comments].where('id = ?',comment_id).update(:response_text => response_text)
  end
  
  def mark_comment_as_processed_in_db(comment_id)
    DB[:comments].where('id = ?',comment_id).update(:processed => true,:posted_response_on => Date.today)
  end
  
end
