# frozen_string_literal: true

class Importer
  class << self
    def import
      import_from_valve_rank_extractor
      import_from_hltv_extractor
      AssetImporter.new.import
    end

    private

    def import_from_valve_rank_extractor
      ranking_data = JSON.parse(ValveRankExtractor::FILE_PATH.read, symbolize_names: true)

      ranking_data.each do |ranking|
        team = Team.where('lower(name) = ?', ranking[:team_name].downcase).first
        team ||= Team.find_by(name: ranking[:team_name])
        team.update(points: ranking[:points], standing: ranking[:standing]) if team.present?
        team ||= Team.create(name: ranking[:team_name], points: ranking[:points], standing: ranking[:standing])
        ranking[:roster].split(', ').each do |nickname|
          team.players.find_or_create_by(nickname: nickname.strip)
        end
      end
    end

    def import_from_hltv_extractor
      hltv_data = JSON.parse(HltvExtractor::FILE_PATH.read, symbolize_names: true)
      hltv_data.each do |hltv_team|
        team = Team.where('lower(name) = ?', hltv_team[:name].downcase).first
        if team.blank?
          Rails.logger.info { "Team not found: #{hltv_team[:name]}" }
          next
        end
        if hltv_team[:current_lineup].present?
          team_update_from_hltv(team, hltv_team)
        else
          Rails.logger.info { "@@@#{team.name}@@@ has no current lineup" }
          next
        end

        hltv_team[:current_lineup].each do |hltv_player|
          player = team.players.find_or_create_by(nickname: hltv_player[:nickname].strip)
          player_update_from_hltv(player, hltv_player)
        end
      end
    end

    def player_update_from_hltv(player, hltv_player)
      player.update(
        {
          name: hltv_player[:name],
          country: hltv_player[:country],
          status: hltv_player[:status],
          hltv_url: hltv_player[:url],
          hltv_id: hltv_player[:id],
          hltv_photo_url: hltv_player[:image_url]
        }.compact
      )
    end

    def team_update_from_hltv(team, hltv_team)
      team.update(
        {
          hltv_id: hltv_team[:team_id],
          hltv_url: hltv_team[:url],
          hltv_path_name: hltv_team[:team_path_name],
          logo_url: hltv_team[:team_logo]
        }.compact
      )
    end
  end
end
