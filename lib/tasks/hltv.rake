# frozen_string_literal: true

namespace :hltv do
  desc 'Fetch Teams Data from HLTV'
  task fetch: :environment do
    HltvExtractor.new.export
  end
end
