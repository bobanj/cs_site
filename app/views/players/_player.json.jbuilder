# frozen_string_literal: true

json.extract! player, :id, :team_id, :name, :country, :nickname, :status, :logo_path, :hltv_url, :hltv_id,
              :hltv_photo_url, :created_at, :updated_at
json.url player_url(player, format: :json)
