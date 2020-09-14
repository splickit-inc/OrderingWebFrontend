class Theme < OpenStruct
  @@s3 = S3::Service.new(access_key_id: Rails.application.secrets.full_access_key,
                         secret_access_key: Rails.application.secrets.secret_full_access_key)

  @@base_bucket = @@s3.buckets.find("com.splickit.products")

  def generate_styles
    stylesheet_template_path = Rails.root.join("public", "theme", "template", "override.css.scss.erb")
    stylesheet_template = ERB.new(File.read(stylesheet_template_path))

    FileUtils::mkdir_p(Rails.root.join("public", "theme", "brands", name, "css"))
    stylesheet_path = Rails.root.join("public", "theme", "brands", name, "css", "#{ name }.css")
    puts "Creating #{ stylesheet_path.relative_path_from(Pathname.pwd).to_s }"
    erb_output = render(stylesheet_template)
    sass_output = Sass::Engine.new(erb_output, syntax: :scss, load_paths: ["./app/assets/stylesheets/all/theme"], style: :compressed).render
    File.write(stylesheet_path, sass_output)
  end

  def generate_javascripts
    javascript_template_path = Rails.root.join("public", "theme", "template", "override.js.erb")
    javascript_template = ERB.new(File.read(javascript_template_path))

    FileUtils::mkdir_p(Rails.root.join("public", "theme", "brands", name, "js"))
    javascript_path = Rails.root.join("public", "theme", "brands", name, "js", "#{ name }.js")
    puts "Creating #{ javascript_path.relative_path_from(Pathname.pwd).to_s }"
    erb_output = render(javascript_template)
    File.write(javascript_path, erb_output)
  end

  def generate_email_templates
    go_admin_template_path   = Rails.root.join("public", "theme", "template", "group-order-admin.mustache.erb")
    go_invite_template_path  = Rails.root.join("public", "theme", "template", "group-order-invite.mustache.erb")

    go_admin_template   = ERB.new(File.read(go_admin_template_path))
    go_invite_template  = ERB.new(File.read(go_invite_template_path))

    # generate group order admin email
    FileUtils::mkdir_p(Rails.root.join("public", "theme", "brands", name, "email", "group-ordering"))
    go_admin_template_path = Rails.root.join("public", "theme", "brands", name, "email", "group-ordering", "admin.mustache")
    puts "Creating #{ go_admin_template_path.relative_path_from(Pathname.pwd).to_s }"
    erb_output = render(go_admin_template)
    File.write(go_admin_template_path, erb_output)

    # generate group order invite email
    FileUtils::mkdir_p(Rails.root.join("public", "theme", "brands", name, "email", "group-ordering"))
    go_invite_template_path = Rails.root.join("public", "theme", "brands", name, "email", "group-ordering", "invite.mustache")
    puts "Creating #{ go_invite_template_path.relative_path_from(Pathname.pwd).to_s }"
    erb_output = render(go_invite_template)
    File.write(go_invite_template_path, erb_output)
  end

  def generate
    generate_styles
    generate_javascripts
    generate_email_templates
  end

  def upload_styles(env = "development")
    Dir[File.join(theme_directory, "css", "*.css")].each do |css_file|
      puts "uploading: #{ env }.#{ File.basename(css_file) }"
      s3_file = @@base_bucket.objects.build("#{ aws_folder }/web/css/#{ env }.#{ File.basename(css_file) }")
      s3_file.content = open(css_file)
      s3_file.acl = :public_read
      s3_file.content_type = "text/css"
      s3_file.save
    end
  end

  def upload_javascripts(env = "development")
    Dir[File.join(theme_directory, "js", "*.js")].each do |js_file|
      puts "uploading: #{ env }.#{File.basename(js_file)}"
      s3_file = @@base_bucket.objects.build("#{ aws_folder }/web/js/#{ env }.#{ File.basename(js_file) }")
      s3_file.content = open(js_file)
      s3_file.acl = :public_read
      s3_file.content_type = "application/js"
      s3_file.save
    end
  end

  def upload_email_templates(env = "development")
    Dir[File.join(theme_directory, "email", "group-ordering", "*.mustache")].each do |email_file|
      puts "uploading: #{ env }.#{ File.basename(email_file) }"
      s3_file = @@base_bucket.objects.build("#{ aws_folder }/email/group-ordering/#{ env }.#{ File.basename(email_file) }")
      s3_file.content = open(email_file)
      s3_file.acl = :public_read
      s3_file.content_type = "text/html"
      s3_file.save
    end
  end

  def upload_fonts(env = "development")
    Dir[File.join(theme_directory, "fonts", "*.*")].each do |font_file|
      puts "uploading: #{ env }.#{ File.basename(font_file) }"
      s3_file = @@base_bucket.objects.build("#{ aws_folder }/web/brand-assets/fonts/#{ File.basename(font_file) }")
      s3_file.content = open(font_file)
      s3_file.acl = :public_read
      s3_file.content_type = "application/font-sfnt"
      s3_file.save
    end
  end

  def upload_favicons
    Dir[File.join(theme_directory, "images", "*.ico")].each do |ico_file|
      puts "uploading: #{ aws_folder }/web/brand-assets/#{ name }.ico"
      s3_file = @@base_bucket.objects.build("#{ aws_folder }/web/brand-assets/#{ File.basename(ico_file) }")
      s3_file.content = open(ico_file)
      s3_file.acl = :public_read
      s3_file.content_type = "image/ico"
      s3_file.save
    end
  end

  def upload(env = "development")
    upload_styles(env)
    upload_javascripts(env)
    upload_email_templates(env)
    upload_fonts(env)
  end

  private

  def render(template)
    template.result(binding)
  end
end