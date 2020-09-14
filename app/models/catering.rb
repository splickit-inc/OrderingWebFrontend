class Catering < BaseModel
  attr_accessor :number_of_people, :timestamp_of_event, :merchant_id, :contact_name, :contact_phone, :notes

  def self.create(params, credentials)
    parse_response(API.post("/catering", params.to_json, credentials))
  end

  def self.times(params, available_times, credentials, utc_date)
    return [] unless available_times.present? && available_times["daily_time"].first.present?
    return available_times["daily_time"].first unless utc_date.present?
    available_times["daily_time"].each do |date_times|
      return date_times if date_times.first.present? &&
          Catering.catering_dates_match(available_times["time_zone"], date_times.first['ts'], utc_date.to_i)
    end
    return []
  end

  private
  def self.catering_dates_match(time_zone, date_time, utc_date)
    return false unless date_time.present? && utc_date.present?
    time_zone = "America/Chicago" unless time_zone.present?
    dt_utc = Time.at(date_time).utc
    d_utc = Time.at(utc_date).utc
    dt = DateTime.parse(dt_utc.to_s).in_time_zone(time_zone).to_date
    d = DateTime.parse(d_utc.to_s).to_date
    return dt == d
  end
end
