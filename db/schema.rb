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

ActiveRecord::Schema.define(:version => 20120705055226) do

  create_table "file_entities", :force => true do |t|
    t.string   "attach_file_name"
    t.string   "attach_content_type"
    t.integer  "attach_file_size"
    t.datetime "attach_updated_at"
    t.string   "original_file_name"
    t.string   "md5"
    t.boolean  "merged",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_entities", ["md5"], :name => "index_file_entities_on_md5"

  create_table "media_resources", :force => true do |t|
    t.integer  "file_entity_id"
    t.string   "name"
    t.boolean  "is_dir",         :default => false
    t.integer  "dir_id",         :default => 0
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fileops_time"
    t.boolean  "is_removed",     :default => false
  end

  add_index "media_resources", ["creator_id"], :name => "index_media_resources_on_creator_id"
  add_index "media_resources", ["dir_id"], :name => "index_media_resources_on_dir_id"
  add_index "media_resources", ["file_entity_id"], :name => "index_media_resources_on_file_entity_id"
  add_index "media_resources", ["fileops_time"], :name => "index_media_resources_on_fileops_time"
  add_index "media_resources", ["name"], :name => "index_media_resources_on_name"

  create_table "online_records", :force => true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "online_records", ["key"], :name => "index_online_records_on_key"
  add_index "online_records", ["user_id"], :name => "index_online_records_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",                      :default => "", :null => false
    t.string   "hashed_password",           :default => "", :null => false
    t.string   "salt",                      :default => "", :null => false
    t.string   "email",                     :default => "", :null => false
    t.string   "sign"
    t.string   "activation_code"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "activated_at"
    t.string   "reset_password_code"
    t.datetime "reset_password_code_until"
    t.datetime "last_login_time"
    t.boolean  "send_invite_email"
    t.integer  "reputation",                :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
