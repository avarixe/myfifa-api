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

ActiveRecord::Schema.define(version: 20180701045042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contract_histories", force: :cascade do |t|
    t.bigint "contract_id"
    t.date "datestamp"
    t.integer "wage"
    t.integer "signing_bonus"
    t.integer "release_clause"
    t.integer "performance_bonus"
    t.integer "bonus_req"
    t.string "bonus_req_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "end_date"
    t.date "effective_date"
    t.index ["contract_id"], name: "index_contract_histories_on_contract_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "player_id"
    t.date "signed_date"
    t.integer "wage"
    t.integer "signing_bonus"
    t.integer "release_clause"
    t.integer "performance_bonus"
    t.integer "bonus_req"
    t.string "bonus_req_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "end_date"
    t.date "effective_date"
    t.index ["player_id"], name: "index_contracts_on_player_id"
  end

  create_table "injuries", force: :cascade do |t|
    t.bigint "player_id"
    t.date "start_date"
    t.date "end_date"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_injuries_on_player_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "player_id"
    t.date "start_date"
    t.date "end_date"
    t.string "destination"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_loans_on_player_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "player_histories", force: :cascade do |t|
    t.bigint "player_id"
    t.date "datestamp"
    t.integer "ovr"
    t.integer "value"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_player_histories_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.string "nationality"
    t.string "pos"
    t.text "sec_pos"
    t.integer "ovr"
    t.integer "value"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.boolean "youth", default: true
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.date "start_date"
    t.date "current_date"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", default: "$"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "player_id"
    t.date "signed_date"
    t.date "effective_date"
    t.string "origin"
    t.string "destination"
    t.integer "fee"
    t.string "traded_player"
    t.integer "addon_clause"
    t.boolean "loan", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_transfers_on_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
end
