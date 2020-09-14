namespace :cache do  
  desc "Clear cached values for the given merchant id"
  task :clear,[:merchant_id] => :environment  do |t, args|
    matcher = "/merchants/#{args[:merchant_id]}*"
    Rails.cache.delete_matched(matcher)
  end
  
  desc "Clear all view fragments"
  task :clear_views => :environment do |t, args|
    matcher = "/merchants*"
    Rails.cache.delete_matched(matcher)
  end
  
  desc "Clear a specific cached skin"
  task :clear_skin,[:skin] => :environment do |t, args|
    matcher = "get_skin_#{args[:skin]}*"
    Rails.cache.delete_matched(matcher)
  end
  
  desc "Clear all cached values"
  task :clear_all => :environment do |t, args|
    Rails.cache.clear
  end
  
  desc "Warm the cache"
  task :warm => :environment do |t, args|
    skins = [:tullys, :fuddruckers, :tasty8s, :masterpiece, :hangar]
    skins.each do |skin|
      Skin.where :skin_identifier=>skin.to_s
      Skin.current_name = skin.to_s
      merchants = Merchant.where
      merchants[:merchants].each do |merchant|
        Merchant.find merchant.merchant_id
        Faraday.new("#{Rails.application.config.hostname}/merchants/#{merchant.merchant_id}?override_skin=#{skin.to_s}").get
      end
    end
  end  
end
