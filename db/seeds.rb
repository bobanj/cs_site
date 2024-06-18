# frozen_string_literal: true

require 'fileutils'
@extensions = Set.new
@no_logo_items = []
BASE_URL = 'https://img-cdn.hltv.org'
@connection = Faraday.new(url: BASE_URL) do |faraday|
  faraday.response :follow_redirects
  faraday.use :cookie_jar
  faraday.adapter Faraday.default_adapter
end

def create_from_ranking
  ranking_file = Rails.root.join('lib/data/ranking_data.json').read
  ranking_data = JSON.parse(ranking_file, symbolize_names: true)

  ranking_data.each do |ranking|
    team = Team.where('lower(name) = ?', ranking[:team_name].downcase).first
    team ||= Team.create(name: ranking[:team_name], points: ranking[:points], standing: ranking[:standing])
    ranking[:roster].split(', ').each do |nickname|
      team.players.find_or_create_by(nickname: nickname.strip)
    end
  end
end

def create_from_hltv
  hltv_file = Rails.root.join('lib/data/hltv_data.json').read
  hltv_data = JSON.parse(hltv_file, symbolize_names: true)

  hltv_data.each do |team|
    this_team = Team.where('lower(name) = ?', team[:name].strip.downcase).first
    if this_team.blank?
      Rails.logger.debug { "Team not found: #{team[:name]}" }
      next
    end

    this_team.update(
      hltv_id: team[:team_id],
      hltv_url: team[:url],
      hltv_path_name: team[:team_path_name],
      logo_url: team[:team_logo]
    )
    if team[:current_lineup].blank?
      Rails.logger.debug { "@@@#{this_team.name}@@@ has no current lineup" }
      next
    end
    team[:current_lineup].each do |player|
      this_player = this_team.players.find_or_create_by(nickname: player[:nickname].strip)
      this_player.update(
        name: player[:name],
        country: player[:country],
        status: player[:status],
        hltv_url: player[:url],
        hltv_id: player[:id],
        hltv_photo_url: player[:image_url]
      )
    end
  end
end

def get_image_data(url)
  sleep_random
  response = @connection.get(url.gsub(BASE_URL, ''))
  unless response.success?
    Rails.logger.debug { "Failed to fetch the image. Status: #{response.status}" }
    return { extension: nil, io: nil }
  end
  io = StringIO.new(response.body)
  extension = begin
    FastImage.type(io)
  rescue StandardError
    nil
  end
  { extension:, io: }
end

def sleep_random
  sleep(rand(2.0..6.0).round(2))
end

def save_image(path, io)
  return if File.exist?(path)

  File.binwrite(path, io.read)
end

def setup_placeholder_image(object)
  logo_dir_path = "app/assets/images/#{object.class.name.downcase.pluralize}"
  FileUtils.mkdir_p Rails.root.join(logo_dir_path)
  logo_path = Rails.root.join(logo_dir_path, 'placeholder.png')
  object.update(logo_path:)
end

def process_image(object)
  return if object.logo_path.present?

  if object.logo_url.starts_with?('/')
    setup_placeholder_image(object)
    return
  end
  image_data = get_image_data(object.logo_url)
  extension = image_data[:extension]
  if extension.blank?
    no_logo_item = { object.class.name.downcase.to_sym => object.id }
    Rails.logger.debug { "NO LOGO: #{no_logo_item}" }
    @no_logo_items << no_logo_item
    return
  end
  @extensions << extension
  logo_dir_path = "app/assets/images/#{object.class.name.downcase.pluralize}"
  FileUtils.mkdir_p Rails.root.join(logo_dir_path)
  logo_path = Rails.root.join(logo_dir_path, "#{object.logo_name}.#{extension}")
  return if File.exist?(logo_path)

  object.update(logo_path:)
  save_image(logo_path, image_data[:io])
end

def import_assets
  Team.find_each do |team|
    process_image(team) if team.logo_url.present?
    team.players.each do |player|
      process_image(player) if player.hltv_photo_url.present?
    end
  end
end

def main
  # create_from_ranking
  # create_from_hltv
  import_assets
  Rails.logger.debug { "Extensions: #{@extensions.to_a}" }
end

main
