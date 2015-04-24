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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 8) do

  create_table "logs", force: :cascade do |t|
    t.string   "message"
    t.string   "remote_host"
    t.string   "cn"
    t.string   "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "network_access_list", id: false, force: :cascade do |t|
    t.integer  "network_role_id"
    t.string   "address"
    t.string   "port"
    t.string   "protocol"
    t.boolean  "permit",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "network_groups", id: false, force: :cascade do |t|
    t.integer  "network_role_id"
    t.string   "ldap_group_name"
    t.boolean  "permit",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "network_roles", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "trusted_ips", id: false, force: :cascade do |t|
    t.integer  "user_id"
    t.string   "ip"
    t.string   "hostname"
    t.integer  "access_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "method",          default: "password"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "picture"
    t.string   "secret"
    t.text     "cert"
    t.text     "key"
    t.boolean  "activated",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
