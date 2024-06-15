# frozen_string_literal: true

namespace :hltv do
  desc 'Fetch Teams Data from HLTV'

  task fetch: :environment do
    Hltv.new.export
  end
end
