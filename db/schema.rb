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

ActiveRecord::Schema.define(:version => 20110703214842) do

  create_table "archives", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "locale"
    t.integer  "position"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conferences", :force => true do |t|
    t.string   "code"
    t.string   "title_ja"
    t.string   "title_en"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_files", :force => true do |t|
    t.string   "key"
    t.text     "context"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", :force => true do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conference_id"
  end

  create_table "event_presenters", :force => true do |t|
    t.integer  "event_id"
    t.integer  "presenter_id"
    t.integer  "presenter_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.string   "kind"
    t.text     "abstract"
    t.string   "locale"
    t.string   "language"
    t.string   "code"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "position"
    t.integer  "day_id"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_event_id"
    t.integer  "conference_id"
  end

  create_table "presenters", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.text     "bio"
    t.string   "locale"
    t.string   "affiliation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gravatar"
  end

  create_table "rooms", :force => true do |t|
    t.string   "code"
    t.string   "floor"
    t.string   "name"
    t.integer  "position"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conference_id"
  end

end
