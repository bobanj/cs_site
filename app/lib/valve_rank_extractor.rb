# frozen_string_literal: true

class ValveRankExtractor
  BASE_URL = 'https://raw.githubusercontent.com'
  STANDINGS_ENDPOINT = '/ValveSoftware/counter-strike_regional_standings/refs/heads/main/live/2024/standings_global_2024_08_06.md'
  FILE_PATH = Rails.root.join('lib/data/ranking_data.json')
  PREV_STANDINGS_FILE_PATH = Rails.root.join('lib/data/standings_global.md')
  STANDING_INDEX = 0
  POINTS_INDEX = 1
  TEAM_NAME_INDEX = 2
  ROSTER_INDEX = 3

  class GlobalRankingUnavailableError < StandardError; end
  class GlobalRankingResponseError < StandardError; end

  attr_reader :teams_ranking

  def initialize
    FileUtils.mkdir_p(Rails.root.join('lib/data'))

    @teams_ranking = []
    @conn = create_connection
    @current_response = nil
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def new_global_ranking?
    if all_teams_ranking.blank? || !PREV_STANDINGS_FILE_PATH.exist?
      return false # TODO: remove this once figuring out how to fetch prev standings
      # raise GlobalRankingUnavailableError, 'Global ranking data is not available'
    end

    @current_response.body != PREV_STANDINGS_FILE_PATH.read
  end

  def update_ranking_file
    return unless new_global_ranking?
    raise GlobalRankingResponseError, '[update_ranking_file]' if @current_response.blank?

    File.write(PREV_STANDINGS_FILE_PATH, @current_response.body)
  end

  def all_teams_ranking
    return @teams_ranking if @teams_ranking.present?

    fetch_teams_ranking
  end

  def export
    return if all_teams_ranking.blank?

    File.write(FILE_PATH, JSON.pretty_generate(all_teams_ranking))
  end

  private

  def create_connection
    Faraday.new(url: BASE_URL) do |faraday|
      faraday.response :follow_redirects
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch_teams_ranking
    page = get_parsed_page(STANDINGS_ENDPOINT)
    page.css('table tbody tr').each do |row|
      row_cells = row.xpath('td').map { |td| td.text.strip }
      @teams_ranking << {
        standing: row_cells[STANDING_INDEX].to_i,
        points: row_cells[POINTS_INDEX].to_i,
        team_name: row_cells[TEAM_NAME_INDEX],
        roster: row_cells[ROSTER_INDEX]
      }
    end
    @teams_ranking
  end

  def get_parsed_page(endpoint)
    sleep(rand(1.0..3.0).round(2))
    @current_response = @conn.get(endpoint)
    Nokogiri::HTML(@markdown.render(@current_response.body))
  end
end
