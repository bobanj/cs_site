# frozen_string_literal: true

class HltvExtractor
  BASE_URL = 'https://www.hltv.org'
  HLTV_COOKIE_TIMEZONE = 'Europe/Berlin'
  FILE_PATH = Rails.root.join('lib/data/hltv_data.json')
  # CookieConsent is a cookie that is set by the website to track the user's consent to cookies
  # Needs to be filled manually before running the script
  # You can fetch the value from the browser's developer tools (cookies)
  COOKIE_CONSENT = ''
  HEADERS = {
    'Referer' => "#{BASE_URL}/stats",
    'Cookie' => "hltvTimeZone=#{HLTV_COOKIE_TIMEZONE};CookieConsent=#{COOKIE_CONSENT};"
  }.freeze

  def initialize
    @teams_names = valve_teams_names
    @teams_info = []
    @conn = create_connection
    @logger = Logger.new($stdout)
  end

  def all_teams_info
    return @teams_info if @teams_info.present?

    @teams_info = _fetch
  end

  def export
    return if all_teams_info.blank?

    File.write(FILE_PATH, JSON.pretty_generate(all_teams_info))
  end

  def get_team_info(hltv_team_id)
    Rails.logger.info { "### Getting team info for team_id: #{hltv_team_id} ###" }
    page = get_parsed_page('/', { pageid: 179, teamid: hltv_team_id })
    team_info = extract_team_info(page, hltv_team_id)
    Rails.logger.info { "@@@ Team info extracted: #{team_info} @@@" }
    team_info[:current_lineup] = get_current_lineup(hltv_team_id, team_info[:team_path_name])
    team_info[:stats] = extract_team_stats(page)
    team_info
  end

  private

  def create_connection
    Faraday.new(url: BASE_URL, headers: HEADERS) do |faraday|
      faraday.response :follow_redirects
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch
    result = []
    teams = get_parsed_page('/stats/teams', { minMapCount: 0 })
    teams.css('td.teamCol-teams-overview a').each do |a_tag|
      next unless @teams_names.include?(a_tag.text.strip.downcase)

      team_id = a_tag['href'].split('/').second_to_last.to_i
      team_data = get_team_info(team_id)
      data = { name: a_tag.text.strip, url: "#{BASE_URL}#{a_tag['href']}" }.merge(team_data)
      result << data
    end
    result
  end

  def valve_teams_names
    teams_names = Set.new
    JSON.parse(File.read(ValveRankExtractor::FILE_PATH), symbolize_names: true).each do |team|
      teams_names << team[:team_name].downcase
    end
    teams_names
  end

  def get_response(endpoint, params = {}, other_browser: false)
    sleep(rand(1.0..3.0).round(2))
    response = @conn.get(endpoint) do |request|
      request.headers['User-Agent'] = Faker::Internet.user_agent if other_browser
      request.params = params
      request
    end
    Nokogiri::HTML(response.body)
  end

  def get_parsed_page(endpoint, params = {}, other_browser: false)
    result = get_response(endpoint, params, other_browser:)
    counter = 0
    while result.text.include?('Just a moment...') && counter < 5
      Rails.logger.info { "Just a moment #{counter}..." }
      counter += 1
      sleep(counter)
      result = get_response(endpoint, params, other_browser: true)
    end
    result
  end

  def extract_team_info(page, team_id)
    {
      team_path_name: extract_path_name(page),
      team_name: page.css('div.context-item').text.strip,
      team_logo: page.css('.leftCol .context-item-image').attr('src')&.value,
      team_id:
    }
  end

  def extract_team_stats(page)
    stats = {}
    page.css('div.columns div.col.standard-box.big-padding').each do |stat|
      key = stat.css('div.small-label-below').text.strip
      value = stat.css('div.large-strong').text.strip
      stats[key] = value
    end
    stats
  end

  def extract_path_name(page)
    page.css('.stats-top-menu-item').attr('href')&.value&.split('/')&.last
  end

  def get_current_lineup(team_id, team_path_name)
    lineup_page = get_parsed_page("/team/#{team_id}/#{team_path_name}#tab-rosterBox")
    lineup_page.css('table.players-table tbody tr').map do |row|
      {
        country: row.css('.players-cell img').attr('alt').value,
        name: row.css('img.playerBox-bodyshot').attr('title')&.value&.gsub(/'.*'/, '')&.gsub(/\s+/, ' ')&.strip,
        nickname: row.css('.players-cell .text-ellipsis').text.strip,
        status: row.css('.players-cell.status-cell').text.strip,
        url: BASE_URL + row.css('a.playersBox-playernick-image.a-reset').attr('href').value,
        image_url: row.css('img.playerBox-bodyshot').attr('src')&.value,
        id: row.css('a.playersBox-playernick-image.a-reset').attr('href').value.split('/').second_to_last.to_i
      }
    end
  end
end
