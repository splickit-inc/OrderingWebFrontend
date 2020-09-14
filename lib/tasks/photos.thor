require "aws-sdk"
require "mysql2"
require "thor"
require "net/http"

class Photos < Thor
  secrets_path = File.join "config", "secrets.yml"
  secrets = YAML.load(File.read(secrets_path))["default"]

  S3_CREDENTIALS = { access_key_id: secrets['access_key'],
                     secret_access_key: secrets['secret_access_key'],
                     region: "us-east-1" }

  DB_DATA = { test: { host: "rds-test.splickit.com",
                      username: "itsquik",
                      password: "It$Qu1k3r",
                      database: "smaw_test" },
              production: { host: "rds-prod.splickit.com",
                            username: "itsquik",
                            password: "It$Qu1k3r",
                            database: "smaw_prod" } }

  SMALL_1X_WIDTH  = 79
  SMALL_1X_HEIGHT = 79
  SMALL_2X_WIDTH  = 158
  SMALL_2X_HEIGHT = 158
  LARGE_1X_WIDTH  = 320
  LARGE_1X_HEIGHT = 210
  LARGE_2X_WIDTH  = 640
  LARGE_2X_HEIGHT = 420

  desc "update photos [skin_name, env]", "update brand photo data"
  def update(skin_name, env = :test)
    s3_client = Aws::S3::Client.new(S3_CREDENTIALS)
    sql_client = Mysql2::Client.new(DB_DATA[env.to_sym])

    if skin_name == "all"
      puts "Finding all valid skins..."
      skin_names = all_active_skin_names(sql_client)
      skin_names = formatted_skin_names(skin_names)
      skin_names = valid_s3_skin_names(skin_names)
    else
      skin_names = [skin_name]
    end

    skin_names.each do |skin_name|
      puts "Updating '#{ env }:#{ skin_name }'"

      s3_image_ids = s3_image_ids(s3_client, skin_name)
      smaw_item_ids = smaw_item_ids(s3_image_ids, sql_client)
      smaw_item_ids.each do |item_id|
        puts "updating #{item_id}"
        if s3_image_exists?(item_id, s3_image_ids)
          sql_client.query("DELETE FROM Photo WHERE item_id=#{item_id}")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/small/1x/#{item_id}.jpg"}', #{SMALL_1X_WIDTH}, #{SMALL_1X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/small/2x/#{item_id}.jpg"}', #{SMALL_2X_WIDTH}, #{SMALL_2X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/large/1x/#{item_id}.jpg"}', #{LARGE_1X_WIDTH}, #{LARGE_1X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/large/2x/#{item_id}.jpg"}', #{LARGE_2X_WIDTH}, #{LARGE_2X_HEIGHT})")
        else
          sql_client.query("DELETE FROM Photo WHERE item_id=#{item_id}")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/small/1x/default-image.jpg"}', #{SMALL_1X_WIDTH}, #{SMALL_1X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/small/2x/default-image.jpg"}', #{SMALL_2X_WIDTH}, #{SMALL_2X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/large/1x/default-image.jpg"}', #{LARGE_1X_WIDTH}, #{LARGE_1X_HEIGHT})")
          sql_client.query("INSERT INTO Photo(item_id, url, width, height) VALUES (#{item_id}, '#{"https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/large/2x/default-image.jpg"}', #{LARGE_2X_WIDTH}, #{LARGE_2X_HEIGHT})")
        end
      end
      puts "Finished update"
    end
  end

  private

  def all_active_skin_names(sql_client)
    sql_client.query("SELECT external_identifier FROM Skin").collect { |row| row["external_identifier"] }
  end

  def formatted_skin_names(skin_names)
    skin_names.map { |skin_name| skin_name.gsub(/^com.splickit./, "") }
  end

  def valid_s3_skin_names(skin_names)
    skin_names.select do |skin_name|
      Net::HTTP.get_response(URI("https://d38o1hjtj2mzwt.cloudfront.net/com.splickit.#{skin_name}/menu-item-images/small/1x/default-image.jpg")).code.to_i == 200
    end
  end

  def item_photos(sql_client, photo)
    sql_client.query("SELECT * FROM Photo WHERE item_id=#{photo["item_id"]}")
  end

  def already_default_image?(photo)
    photo["url"] =~ /default-image/
  end

  def s3_image_exists?(smaw_image_id, s3_image_ids)
    s3_image_ids.include?(smaw_image_id)
  end

  def menu_type_ids(image_ids, sql_client)
    menu_type_ids = []

    image_ids.each do |image_id|
      menu_type = sql_client.query("SELECT menu_type_id FROM Item WHERE item_id=#{image_id}")
      menu_type_ids << menu_type.first["menu_type_id"] if menu_type.first
    end

    menu_type_ids.uniq
  end

  def smaw_item_ids(image_ids, sql_client)
    item_ids = []

    menu_type_ids(image_ids, sql_client).each do |menu_type_id|
      sql_client.query("SELECT item_id FROM Item where menu_type_id='#{menu_type_id}'").each do |row|
        item_ids << row["item_id"]
      end
    end

    item_ids.uniq
  end

  def s3_image_ids(s3_client, skin_name)
    s3_image_objects(s3_client, skin_name).map do |object|
      object.key.to_s.split('/').last.match(/\d{2,}/)[0].to_i
    end
  end

  def s3_image_objects(s3_client, skin_name)
    images_list = []
    prefix = "com.splickit.#{ skin_name }/menu-item-images/large/1x/"
    is_truncated = true
    next_token = ""

    while is_truncated
      get_object_params = { bucket: "com.splickit.products", prefix: prefix }

      get_object_params.merge!(continuation_token: next_token) unless next_token.empty?

      response = s3_client.list_objects_v2(get_object_params)
      next_token = response.next_continuation_token
      is_truncated = response.is_truncated

      images_list.concat(response.contents.select { |object| object.key =~ /^#{ prefix }\d{1,}.jpg/ })
    end

    images_list
  end
end
