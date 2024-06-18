# frozen_string_literal: true

json.extract! team, :id, :name, :logo_url, :logo_path, :hltv_id, :hltv_path_name, :hltv_url, :points, :standing,
              :status, :created_at, :updated_at
json.url team_url(team, format: :json)
