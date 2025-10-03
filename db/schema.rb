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

ActiveRecord::Schema[7.2].define(version: 2025_10_02_192528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "installations", force: :cascade do |t|
    t.string "nation_slug", null: false
    t.string "access_token", null: false
    t.string "refresh_token", null: false
    t.datetime "expires_at", null: false
    t.string "token_type", default: "Bearer"
    t.string "scope"
    t.string "status", default: "active", null: false
    t.datetime "installed_at", null: false
    t.datetime "last_used_at", null: false
    t.datetime "uninstalled_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_installations_on_expires_at"
    t.index ["last_used_at"], name: "index_installations_on_last_used_at"
    t.index ["nation_slug"], name: "index_installations_on_nation_slug", unique: true
    t.index ["status"], name: "index_installations_on_status"
  end
end
