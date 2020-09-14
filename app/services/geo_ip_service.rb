class GeoIPService

  def self.find(ip)
    parsed_response = parse_response(
        Faraday.new("http://geoip3.maxmind.com/").get(
        "/b?l=9dTTeej5EwG7&i=#{ip}"
      )
    )

    lat = parsed_response[-2]
    lng = parsed_response[-1]
    if !lat.empty? && !lng.empty?
      [lat,lng]
    else
      nil
    end
  end

  private

  def self.parse_response(response)
    response.body.split(',')
  end

end
