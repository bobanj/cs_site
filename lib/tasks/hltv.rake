# frozen_string_literal: true

namespace :hltv do
  desc 'Fetch Teams Data from HLTV'
  task fetch: :environment do
    Hltv.new.export
  end

  desc 'Update team based on team_id from hltv'
  task :update_team, %i[team_id team_name] => :environment do |_t, args|
    team_id = args.team_id.to_i
    team_name = args.team_name.to_s.strip
    if team_id.zero?
      puts 'Please provide a team_id'
    elsif team_name.blank?
      puts 'Please provide a team_name'
    else
      Hltv.new.update_team(team_id, team_name)
    end
  end
end
