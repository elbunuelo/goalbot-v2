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

ActiveRecord::Schema[7.0].define(version: 2024_06_13_232634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.integer "start_timestamp"
    t.integer "previous_leg_ss_id"
    t.integer "ss_id"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "home_team_id", null: false
    t.bigint "away_team_id", null: false
    t.date "date"
    t.integer "last_incident_seen"
    t.boolean "finished"
    t.string "tournament"
    t.bigint "tournament_id"
    t.index ["away_team_id"], name: "index_events_on_away_team_id"
    t.index ["home_team_id"], name: "index_events_on_home_team_id"
    t.index ["tournament_id"], name: "index_events_on_tournament_id"
  end

  create_table "incident_messages", force: :cascade do |t|
    t.bigint "incident_id", null: false
    t.bigint "subscription_id", null: false
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_incident_messages_on_incident_id"
    t.index ["subscription_id"], name: "index_incident_messages_on_subscription_id"
  end

  create_table "incidents", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "player_name"
    t.string "reason"
    t.string "incident_class"
    t.string "incident_type"
    t.integer "time"
    t.integer "ss_id"
    t.boolean "is_home"
    t.string "text"
    t.integer "home_score"
    t.integer "away_score"
    t.integer "added_time"
    t.string "player_in"
    t.string "player_out"
    t.integer "length"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "searching_since"
    t.string "video_url"
    t.boolean "search_suspended", default: false
    t.boolean "notifications_sent"
    t.index ["event_id"], name: "index_incidents_on_event_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.integer "ss_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_caches", force: :cascade do |t|
    t.string "search"
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_search_caches_on_team_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.string "year"
    t.string "ss_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_seasons_on_tournament_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "service"
    t.string "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_subscriptions_on_event_id"
  end

  create_table "team_aliases", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_aliases_on_team_id"
  end

  create_table "team_subscriptions", force: :cascade do |t|
    t.string "conversation_id"
    t.string "service"
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_subscriptions_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "short_name"
    t.string "ss_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tournament_aliases", force: :cascade do |t|
    t.string "alias"
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_aliases_on_tournament_id"
  end

  create_table "tournament_subscriptions", force: :cascade do |t|
    t.string "service"
    t.string "conversation_id"
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_subscriptions_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "ss_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "events", "teams", column: "away_team_id"
  add_foreign_key "events", "teams", column: "home_team_id"
  add_foreign_key "events", "tournaments"
  add_foreign_key "incident_messages", "incidents"
  add_foreign_key "incident_messages", "subscriptions"
  add_foreign_key "incidents", "events"
  add_foreign_key "search_caches", "teams"
  add_foreign_key "seasons", "tournaments"
  add_foreign_key "subscriptions", "events"
  add_foreign_key "team_aliases", "teams"
  add_foreign_key "team_subscriptions", "teams"
  add_foreign_key "tournament_aliases", "tournaments"
  add_foreign_key "tournament_subscriptions", "tournaments"
end
