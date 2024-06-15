# frozen_string_literal: true

namespace :ranking do
  desc 'Fetch Ranking Data from Valve'

  task fetch: :environment do
    ValveRank.new.export
  end
end
