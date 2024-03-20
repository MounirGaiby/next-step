class HolidayService
  require 'net/http'
  require 'uri'
  require 'json'

  def get_holidays(start_date = Time.now.beginning_of_year, end_date = Time.now.end_of_year, region = 'ma',
                   locale = 'fr')
    response = Rails.cache.fetch("holidays-#{region}-#{locale}", expires_in: 60.minutes) do
      base_url = "https://www.googleapis.com/calendar/v3/calendars/#{locale}.#{region}%23holiday@group.v.calendar.google.com/events"
      params = "?key=#{ENV['GOOGLE_API_KEY']}&timeMin=#{start_date.strftime('%Y-%m-%dT00:00:00Z')}&timeMax=#{end_date.strftime('%Y-%m-%dT00:00:00Z')}"
      url = URI.parse(base_url + params)
      Net::HTTP.get_response(url)
    end
    format_holidays(JSON.parse(response.body)['items']) if response.is_a?(Net::HTTPSuccess)
  end

  private

  def format_holidays(holidays)
    seen_names = []
    formated_holidays = holidays.map do |holiday|
      next if seen_names.include?(holiday['summary'])

      seen_names << holiday['summary']

      { name: holiday['summary'], start_date: holiday['start']['date'], end_date: holiday['end']['date'] }
    end
    formated_holidays.compact.sort_by { |holiday| holiday[:start_date] }
  end
end
