class RemoveDoorkeeperTables < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
    remove_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"

    drop_table "oauth_access_grants", force: :cascade do |t|
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

    drop_table "oauth_access_tokens", force: :cascade do |t|
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

    drop_table "oauth_applications", force: :cascade do |t|
      t.string "name", null: false
      t.string "uid", null: false
      t.string "secret", null: false
      t.text "redirect_uri", null: false
      t.string "scopes", default: "", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "confidential", default: true
      t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
    end
  end
end
