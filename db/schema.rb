# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_18_053425) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.datetime "expires_at", precision: nil
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_access_tokens_on_token"
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "match_id"
    t.integer "minute"
    t.bigint "player_id"
    t.boolean "red_card", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "player_name"
    t.boolean "home", default: false, null: false
    t.bigint "cap_id"
    t.index ["cap_id"], name: "index_bookings_on_cap_id"
    t.index ["match_id"], name: "index_bookings_on_match_id"
    t.index ["player_id"], name: "index_bookings_on_player_id"
  end

  create_table "caps", force: :cascade do |t|
    t.bigint "match_id"
    t.bigint "player_id"
    t.string "pos"
    t.integer "start", default: 0
    t.integer "stop", default: 90
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "rating"
    t.integer "ovr"
    t.bigint "next_id"
    t.boolean "injured", default: false, null: false
    t.index ["match_id"], name: "index_caps_on_match_id"
    t.index ["next_id"], name: "index_caps_on_next_id"
    t.index ["player_id", "match_id", "start"], name: "index_caps_on_player_id_and_match_id_and_start", unique: true
    t.index ["player_id"], name: "index_caps_on_player_id"
    t.index ["pos", "match_id", "start"], name: "index_caps_on_pos_and_match_id_and_start", unique: true
  end

  create_table "competitions", force: :cascade do |t|
    t.bigint "team_id"
    t.integer "season"
    t.string "name"
    t.string "champion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["season"], name: "index_competitions_on_season"
    t.index ["team_id"], name: "index_competitions_on_team_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "player_id"
    t.date "signed_on"
    t.integer "wage"
    t.integer "signing_bonus"
    t.integer "release_clause"
    t.integer "performance_bonus"
    t.integer "bonus_req"
    t.string "bonus_req_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "ended_on"
    t.date "started_on"
    t.string "conclusion"
    t.bigint "previous_id"
    t.index ["player_id"], name: "index_contracts_on_player_id"
    t.index ["previous_id"], name: "index_contracts_on_previous_id"
  end

  create_table "fixture_legs", force: :cascade do |t|
    t.bigint "fixture_id"
    t.string "home_score"
    t.string "away_score"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["fixture_id"], name: "index_fixture_legs_on_fixture_id"
  end

  create_table "fixtures", force: :cascade do |t|
    t.bigint "stage_id"
    t.string "home_team"
    t.string "away_team"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["stage_id"], name: "index_fixtures_on_stage_id"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "match_id"
    t.integer "minute"
    t.string "player_name"
    t.bigint "player_id"
    t.bigint "assist_id"
    t.boolean "home", default: false, null: false
    t.boolean "own_goal", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "assisted_by"
    t.bigint "cap_id"
    t.bigint "assist_cap_id"
    t.string "set_piece", limit: 20
    t.index ["assist_cap_id"], name: "index_goals_on_assist_cap_id"
    t.index ["assist_id"], name: "index_goals_on_assist_id"
    t.index ["cap_id"], name: "index_goals_on_cap_id"
    t.index ["match_id"], name: "index_goals_on_match_id"
    t.index ["player_id"], name: "index_goals_on_player_id"
  end

  create_table "injuries", force: :cascade do |t|
    t.bigint "player_id"
    t.date "started_on"
    t.date "ended_on"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["player_id"], name: "index_injuries_on_player_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "player_id"
    t.date "started_on"
    t.date "ended_on"
    t.string "destination"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "origin"
    t.date "signed_on"
    t.integer "wage_percentage"
    t.integer "transfer_fee"
    t.integer "addon_clause"
    t.index ["player_id"], name: "index_loans_on_player_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "team_id"
    t.string "home"
    t.string "away"
    t.string "competition"
    t.date "played_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "extra_time", default: false, null: false
    t.integer "home_score", default: 0
    t.integer "away_score", default: 0
    t.string "stage"
    t.boolean "friendly", default: false, null: false
    t.integer "season"
    t.float "home_xg"
    t.float "away_xg"
    t.integer "home_possession", default: 50
    t.integer "away_possession", default: 50
    t.index ["team_id"], name: "index_matches_on_team_id"
  end

  create_table "options", force: :cascade do |t|
    t.bigint "user_id"
    t.string "category"
    t.string "value"
    t.index ["user_id", "category", "value"], name: "index_options_on_user_id_and_category_and_value", unique: true
    t.index ["user_id"], name: "index_options_on_user_id"
  end

  create_table "penalty_shootouts", force: :cascade do |t|
    t.bigint "match_id"
    t.integer "home_score"
    t.integer "away_score"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["match_id"], name: "index_penalty_shootouts_on_match_id"
  end

  create_table "player_histories", force: :cascade do |t|
    t.bigint "player_id"
    t.date "recorded_on"
    t.integer "ovr"
    t.integer "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "kit_no"
    t.index ["player_id"], name: "index_player_histories_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.string "nationality"
    t.string "pos"
    t.text "sec_pos", default: [], array: true
    t.integer "ovr"
    t.integer "value"
    t.integer "birth_year"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
    t.boolean "youth", default: false, null: false
    t.integer "kit_no"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "squad_players", force: :cascade do |t|
    t.bigint "squad_id"
    t.bigint "player_id"
    t.string "pos"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["player_id"], name: "index_squad_players_on_player_id"
    t.index ["squad_id"], name: "index_squad_players_on_squad_id"
  end

  create_table "squads", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["team_id"], name: "index_squads_on_team_id"
  end

  create_table "stages", force: :cascade do |t|
    t.bigint "competition_id"
    t.string "name"
    t.integer "num_teams"
    t.integer "num_fixtures"
    t.boolean "table", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["competition_id"], name: "index_stages_on_competition_id"
  end

  create_table "table_rows", force: :cascade do |t|
    t.bigint "stage_id"
    t.string "name"
    t.integer "wins", default: 0
    t.integer "draws", default: 0
    t.integer "losses", default: 0
    t.integer "goals_for", default: 0
    t.integer "goals_against", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["stage_id"], name: "index_table_rows_on_stage_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.date "started_on"
    t.date "currently_on"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "currency", default: "$"
    t.bigint "previous_id"
    t.string "game"
    t.string "manager_name"
    t.index ["previous_id"], name: "index_teams_on_previous_id"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "player_id"
    t.date "signed_on"
    t.date "moved_on"
    t.string "origin"
    t.string "destination"
    t.integer "fee"
    t.string "traded_player"
    t.integer "addon_clause"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["player_id"], name: "index_transfers_on_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false, null: false
    t.string "username"
    t.boolean "dark_mode", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
