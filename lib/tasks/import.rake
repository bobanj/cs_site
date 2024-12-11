# frozen_string_literal: true

namespace :import do
  desc 'Import Data from Valve and HLTV'

  task all: :environment do
    Importer.import
  end
end
