class CreateAccessTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :access_tokens do |t|
      t.references :user, index: true
      t.string :token, index: true
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
