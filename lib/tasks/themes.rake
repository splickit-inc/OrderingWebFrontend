require 'erb'
require 'sass'
require 'ostruct'
require 's3'
require 'fileutils'
require 'theme'

namespace :themes do
  desc "rake themes:generate"
  task generate: :environment do
    themes_path = Rails.root.join("config", "themes.yml")

    themes_list = YAML.load(File.read themes_path)

    themes_list.each do |theme, data|
      theme = Theme.new(data.merge!(name: theme))
      theme.generate
    end
  end

  desc "rake themes:upload[ENV]"
  task :upload, :env do |t, args|
    Dir.glob(Rails.root.join("public", "theme", "brands", "**")) do |theme_directory|
      theme = File.basename(theme_directory)
      Theme.new(name: theme, theme_directory: Rails.root.join("public", "theme", "brands", theme),
                aws_folder: "com.splickit.#{ theme }").upload(args[:env])
    end
  end

  desc "upload charity logos"
  task :upload_charity, :env do |t, args|
    args.with_defaults(:env => "development")

    s3 = S3::Service.new({
                           :access_key_id => Rails.application.secrets.full_access_key,
                           :secret_access_key => Rails.application.secrets.secret_full_access_key
                         })

    base_bucket = s3.buckets.find("com.splickit.products")

    Dir.glob(Rails.root.join('public', 'theme', 'brands', '**')) do |brand_directory|
      brand_name = "com.splickit.#{File.basename(brand_directory)}"
      web2_image_dir = "#{brand_directory}/images"
      web2_image = "#{web2_image_dir}/charity-logo@2x.png"
      puts "uploading to #{brand_name}/charity/logo.png"
      s3_file = base_bucket.objects.build("#{brand_name}/web/charity/logo.png")
      s3_file.content = open(web2_image)
      s3_file.content_type = "image/png"
      s3_file.save
    end
  end

  desc "uploads the favicon images, rake themes:upload_favicon"
  task :upload_favicon, :env do |t, args|
    Dir.glob(Rails.root.join("public", "theme", "brands", "**")) do |theme_directory|
      theme = File.basename(theme_directory)
      Theme.new(name: theme, theme_directory: Rails.root.join("public", "theme", "brands", theme),
                aws_folder: "com.splickit.#{ theme }").upload_favicons
    end
  end
end
