# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120702095030) do

  create_table "enclosings", :force => true do |t|
    t.integer "parent_folder_id"
    t.integer "file_folder_id"
  end

  create_table "file_entities", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.string   "attachment_updated_at"
    t.string   "original_file_name"
    t.integer  "media_file_id"
    t.string   "md5"
    t.boolean  "merged",                  :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "media_files", :force => true do |t|
    t.integer  "file_entity_id"
    t.integer  "media_folder_id", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "media_folders", :force => true do |t|
    t.string   "name"
    t.integer  "media_folder_id", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

end
