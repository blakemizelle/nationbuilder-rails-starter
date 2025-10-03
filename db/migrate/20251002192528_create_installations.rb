class CreateInstallations < ActiveRecord::Migration[7.2]
  def change
    create_table :installations do |t|
      t.string :nation_slug, null: false
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.string :token_type, default: "Bearer"
      t.string :scope
      t.string :status, default: "active", null: false
      t.datetime :installed_at, null: false
      t.datetime :last_used_at, null: false
      t.datetime :uninstalled_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :installations, :nation_slug, unique: true
    add_index :installations, :status
    add_index :installations, :expires_at
    add_index :installations, :last_used_at
  end
end
