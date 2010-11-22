# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101122131837) do

  create_table "antorchas", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "operations", :force => true do |t|
    t.integer  "message_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operations", ["message_id"], :name => "index_operations_on_message_id", :unique => true

  create_table "zorg_voor_jeugd_aliases", :force => true do |t|
    t.integer  "organization_id",           :null => false
    t.string   "organization_username",     :null => false
    t.string   "organisatie_naam"
    t.string   "organisatie_postcode"
    t.string   "organisatie_uuid"
    t.string   "gebruikersnaam_medewerker", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
