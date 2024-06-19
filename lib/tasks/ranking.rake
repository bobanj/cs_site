# frozen_string_literal: true

namespace :ranking do
  desc 'Fetch Ranking Data from Valve'

  task fetch: :environment do
    ValveRankExtractor.new.export
  end
end
