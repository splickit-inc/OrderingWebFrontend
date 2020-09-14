load 'deploy' if respond_to?(:namespace) # cap2 differentiator
load 'deploy/assets'

require './config/deploy/cap_notify.rb'
require 'airbrake/capistrano'
require 'aws-sdk'
require 'bundler/capistrano'

set :notify_emails, ["devs@splickit.com"]

namespace :bundle do
  task :symlinks, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    puts "IN BUNDLE: ABOUT TO RUN:"
    puts "mkdir -p #{shared_dir} && rm -f #{File.join(shared_dir,"bundle")} && ln -s #{shared_dir} #{release_dir}"
    run("mkdir -p #{shared_dir} && rm -f #{File.join(shared_dir,"bundle")} && ln -s #{shared_dir} #{release_dir}")
  end

  task :install, :except => { :no_release => true } do
    bundle_dir     = fetch(:bundle_dir,         " #{fetch(:shared_path)}/bundle")
    bundle_without = [*fetch(:bundle_without,   [:development, :test])].compact
    bundle_flags   = fetch(:bundle_flags, "--deployment --quiet")
    bundle_gemfile = fetch(:bundle_gemfile,     "Gemfile")
    bundle_cmd     = fetch(:bundle_cmd, "bundle")

    args = ["--gemfile #{fetch(:latest_release)}/#{bundle_gemfile}"]
    args << "--path #{bundle_dir}" unless bundle_dir.to_s.empty?
    args << bundle_flags.to_s
    args << "--without #{bundle_without.join(" ")}" unless bundle_without.empty?

    puts "IN INSTALL: ABOUT TO RUN:"
    puts "#{bundle_cmd} install #{args.join(' ')}"
    run "#{bundle_cmd} install #{args.join(' ')}"
  end
end

after 'deploy:update_code', 'bundle:symlinks'
after "deploy:update_code", "bundle:install"

### multistage (require 'capistrano/ext/multistage')

set :stages, %w( staging tweb07 production localhost_new uat singleproduction otherstaging singleuat )
set :default_stage, "staging"

### require 'capistrano/ext/multistage'

location = fetch(:stage_dir, "config/deploy")
unless exists?(:stages)
  set :stages, Dir["#{location}/*.rb"].map { |f| File.basename(f, ".rb") }
end
stages.each do |name|
  desc "Set the target stage to `#{name}'."
  task(name) do
    set :stage, name.to_sym
    puts "ABOUT TO LOAD #{location}/#{stage}"
    load "#{location}/#{stage}"
  end
end
namespace :multistage do
  desc "[internal] Ensure that a stage has been selected."
  task :ensure do
    if !exists?(:stage)
      if exists?(:default_stage)
        puts "Defaulting to `#{default_stage}'"
        find_and_execute_task(default_stage)
      else
        abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
      end
    end
  end
  desc "Stub out the staging config files."
  task :prepare do
    FileUtils.mkdir_p(location)
    stages.each do |name|
      file = File.join(location, name + ".rb")
      unless File.exists?(file)
        File.open(file, "w") do |f|
          f.puts "# #{name.upcase}-specific deployment configuration"
          f.puts "# please put general deployment config in config/deploy.rb"
        end
      end
    end
  end
end
on :start, "multistage:ensure", :except => stages + ['multistage:prepare']

on :start, "options:process"

namespace :options do
  desc "Show how to read in command line options"
  task :process do
    if( ENV['branch'] )
      p "branch is #{ENV['branch']}"
      set :branch , ENV["branch"]
    else
      set :branch , "master"
    end
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc "Send email notification"
  task :send_notification do
    Notifier.deploy_notification(self).deliver
  end
  
  task :cache_renew, :only => {:primary => true} do
    puts "ABOUT TO RUN:"
    puts "scp pweb01:#{shared_path}/config/* #{shared_path}/config/"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake cache:clear_views"    
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    puts "ABOUT TO RUN:"
    puts "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Run pending migrations on already deployed code"
  task :migrate, :only => {:primary => true}, :except => { :no_release => true } do
    puts "ABOUT TO RUN:"
    puts "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end

  desc "Generate a textual description of the code being deployed"
  task :describe do
    num_commits = 5
    items = []
    deploy_time = Time.now
    items.push "Deployed at: #{deploy_time}"
    deployed_by = (`whoami`).gsub(/\n/,"")
    items.push "Deployed by: #{deployed_by}"
    deployed_branch = fetch(:branch, "master")
    items.push "Deployed branch: #{deployed_branch}"
    last_changes = `git log #{deployed_branch} --format="%H" -n #{num_commits}`
    items.push "Last #{num_commits} commits: \n#{last_changes}"

    report = items.join("\n")
    run "cd #{current_path}; echo '#{report}' > public/deploy.txt"
  end

  desc "Generate robots.txt"
  task :robots do
  run "cd #{current_path}; echo 'User-agent: *' > public/robots.txt; echo 'Disallow: /' >> public/robots.txt"
  end
end

task :link_my_shared_directories do
  symlink_paths = []
  symlink_paths << { source: "#{shared_path}/cache", link: "#{latest_release}/tmp/cache" }
  symlink_paths << { source: "#{shared_path}/config/database.yml", link: "#{latest_release}/config/database.yml" }
  symlink_paths << { source: "#{shared_path}/config/twitter.yml", link: "#{latest_release}/config/twitter.yml" }
  symlink_paths << { source: "#{shared_path}/config/secrets.yml", link: "#{latest_release}/config/secrets.yml" }

  symlink_paths.each do |path|
    puts "LINKING: ABOUT TO RUN:"
    puts "rm -rf #{path[:link]} ; ln -s #{path[:source]} #{path[:link]}"
    run "rm -rf #{path[:link]} ; ln -s #{path[:source]} #{path[:link]}"
  end
end

task :notify do
  log = `git log | head -200`
  log = log.gsub("'","").gsub("\"","")
  whoami = `whoami`.strip
  emails = %w(deployment).map{|e| "#{e}@splickit.com"}.join(",")

  puts "echo '#{log}' | mail -s \" SplickItWeb2 deployed by #{whoami}\" #{emails}"

  `echo '#{log}' | mail -s \" SplickItWeb2 deployed by #{whoami}\" #{emails}`
end

after "deploy", "deploy:describe"
after "deploy", "deploy:cache_renew"
after "deploy:update_code", :link_my_shared_directories
after "deploy:restart", "deploy:cleanup"

set :application, "splickitweb"
set :repository,  "git@github.com:splickit-inc/SplickIt-web-2.git"
set :user, "itsquik"
set :deploy_to, "/usr/local/ordernow/httpd/htdocs/#{ application }"
set :normalize_asset_timestamps, false
set :scm, :git
set :keep_releases, 10

# be sure to run 'ssh-add' on your local machine
system "ssh-add 2>&1" unless ENV['NO_SSH_ADD']
ssh_options[:forward_agent] = true
set :use_sudo, false
