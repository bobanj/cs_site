# frozen_string_literal: true

require 'fileutils'

class AssetImporter
  BASE_URL = 'https://img-cdn.hltv.org'

  def initialize
    @no_logo_items = []
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.response :follow_redirects
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end
  end

  def import
    # Create the directories if they don't exist
    FileUtils.mkdir_p(Rails.root.join('app/assets/images/teams'))
    FileUtils.mkdir_p(Rails.root.join('app/assets/images/players'))

    Team.find_each do |team|
      download_image(team)
      team.players.each do |player|
        download_image(player)
      end
    end
    export_no_logo_items
  end

  private

  def download_image(object)
    # object is either a Team or a Player instance
    return if object.logo_path.present?
    return if already_downloaded?(object)

    @no_logo_items << object and return if object.logo_url.blank?
    setup_placeholder_image(object) and return if object.logo_url.starts_with?('/')

    puts "DOWNLOADING IMAGE FOR #{object.class.name}: #{pom}: #{object.id}"
    io = image_io(object.logo_url.gsub(BASE_URL, ''))
    extension = image_extension(io)
    @no_logo_items << object and return if extension.blank?

    logo_path = "#{object.class.name.downcase.pluralize}/#{object.logo_name}.#{extension}"
    save_image(Rails.root.join("app/assets/images/#{logo_path}"), io)
    object.update(logo_path:)
  end

  def already_downloaded?(object)
    pathname = image_pathname(object)
    pom = object.respond_to?(:nickname) ? object.nickname : object.name
    if pathname&.exist?
      puts "FOUND IMAGE FOR #{object.class.name}: #{pom}: #{object.id}: #{pathname}"
      object.update(logo_path: pathname.sub(Rails.root.join('app/assets/images/').to_s, ''))
      return true
    end
    false
  end

  def setup_placeholder_image(object)
    object.update(logo_path: "#{object.class.name.downcase.pluralize}/placeholder.png")
  end

  def image_extension(io)
    return if io.blank?

    begin
      FastImage.type(io)
    rescue StandardError
      nil
    end
  end

  def sleep_random
    sleep(rand(2.0..6.0).round(2))
  end

  def image_io(url)
    sleep_random
    response = @connection.get(url)
    unless response.success?
      Rails.logger.info { "Failed to fetch the image. Status: #{response.status} URL: #{url}" }
      return nil
    end
    StringIO.new(response.body)
  end

  def save_image(path, io)
    if File.exist?(path)
      Rails.logger.info { "File already exists: #{path}" }
      return
    end

    File.binwrite(path, io.read)
  end

  def image_pathname(object)
    return true if object.logo_path.present? && Rails.root.join("app/assets/images/#{object.logo_path}").exist?

    Rails.root.glob("app/assets/images/#{object.class.name.downcase.pluralize}/#{object.logo_name}.*").first
  end

  def export_no_logo_items
    return if @no_logo_items.blank?

    Rails.root.join('lib/data/no_logo_items.json').write(JSON.pretty_generate(@no_logo_items.map(&:as_json)))
  end
end
