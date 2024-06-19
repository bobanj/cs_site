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

ActiveRecord::Schema[7.1].define(version: 2024_06_19_183951) do
  create_table "players", force: :cascade do |t|
    t.integer "team_id", null: false
    t.string "name"
    t.string "country"
    t.string "nickname"
    t.string "status"
    t.string "logo_path"
    t.string "hltv_url"
    t.integer "hltv_id"
    t.string "hltv_photo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_name", unique: true
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "logo_url"
    t.string "logo_path"
    t.integer "hltv_id"
    t.string "hltv_path_name"
    t.string "hltv_url"
    t.integer "points"
    t.integer "standing"
    t.integer "previous_standing"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_name", unique: true
  end

  add_foreign_key "players", "teams"
end
