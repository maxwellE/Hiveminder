require 'sequel'
require "sqlite3"
DB = Sequel.sqlite('hiveminder.db')
module DbManager
  def create_db_and_table
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
    (DB[:comments][:comment_id => comment_id]).exists?
  end
  
  def insert_comment(comment_id,comment_text)
     DB[:comments].insert(:comment_id=>comment_id, 
     :comment_text => comment_text)
  end
end
