# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.string :country
      t.string :nickname
      t.string :status
      t.string :logo_path
      t.string :hltv_url
      t.integer :hltv_id
      t.string :hltv_photo_url

      t.timestamps
    end
  end
end
