# frozen_string_literal: true

class Team < ApplicationRecord
  NO_DIFF = '-'
  has_paper_trail on: [:update], only: %i[valve_points valve_standing]
  has_many :players, dependent: :destroy
  has_one :previous_version, lambda {
                               order('id desc')
                             }, class_name: 'PaperTrail::Version', as: :item, dependent: nil, inverse_of: false

  def self.get_duplicates(*columns)
    order('created_at ASC').select("#{columns.join(',')}, COUNT(*)").group(columns).having('COUNT(*) > 1')
  end

  def self.update_global_ranking
    valve_rank_extractor = ValveRankExtractor.new
    return unless valve_rank_extractor.new_global_ranking?

    valve_rank_extractor.all_teams_ranking.each do |team_ranking|
      team = Team.find_by(name: team_ranking[:team_name])
      if team.blank?
        Rails.logger.info { "[UpdateGlobalRanking] Team not found: #{team_ranking[:team_name]}" }
        next
      end
      team.update(valve_points: team_ranking[:points], valve_standing: team_ranking[:standing])
    end
    valve_rank_extractor.update_ranking_file
  end

  def valve_points_diff
    return NO_DIFF if previous_valve_points.nil?

    valve_points - previous_valve_points
  end

  def valve_standing_diff
    return NO_DIFF if previous_valve_standing.nil?

    valve_standing - previous_valve_standing
  end

  def previous_valve_points
    return valve_points if previous_version.nil?

    previous_version.reify.valve_points
  end

  def previous_valve_standing
    return valve_standing if previous_version.nil?

    previous_version.reify.valve_standing
  end

  def logo_name
    "#{name.downcase.tr(' ', '_')}_logo"
  end

  def hltv_update; end
end
