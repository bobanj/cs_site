# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :logo_url
      t.string :logo_path
      t.integer :hltv_id
      t.string :hltv_path_name
      t.string :hltv_url
      t.integer :points
      t.integer :standing
      t.integer :previous_standing
      t.string :status

      t.timestamps
      t.index ['name'], name: 'index_teams_name', unique: true
    end
  end
end
