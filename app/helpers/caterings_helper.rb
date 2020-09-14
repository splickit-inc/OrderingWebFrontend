module CateringsHelper
  def times_select_list
    @times.map { |time| [time['time'], time['ts']] }
  end
  def date_time_now_utc(time_zone)
    DateTime.parse(Time.now.to_s).in_time_zone(time_zone).time
  end
end