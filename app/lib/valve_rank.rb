# frozen_string_literal: true

class ValveRank
  BASE_URL = 'https://raw.githubusercontent.com/'
  FILE_PATH = Rails.root.join('lib/data/ranking_data.json')

  def initialize
    @teams_ranking = []
    @conn = create_connection
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def all_teams_ranking
    return @teams_ranking if @teams_ranking.present?

    @teams_ranking = fetch
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

  def fetch
    page = get_parsed_page('/ValveSoftware/counter-strike_regional_standings/main/standings_global.md')
    page.css('table tbody tr').each do |row|
      row_data = row.xpath('td').map(&:text)
      @teams_ranking << {
        standing: row_data[0],
        points: row_data[1],
        team_name: row_data[2],
        roster: row_data[3]
      }
    end
    @teams_ranking
  end

  def get_parsed_page(endpoint)
    sleep(rand(1.0..3.0).round(2))
    response = @conn.get(endpoint)
    Nokogiri::HTML(@markdown.render(response.body))
  end
end
