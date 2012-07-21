dir = File.expand_path(File.dirname(__FILE__))
pusher_config = File.new(dir + "/pusher.yml").read
env = (ENV["RACK_ENV"] || "development")
pusher_settings = YAML::load(pusher_config)[env]

Pusher.app_id = pusher_settings['app_id']
Pusher.key    = pusher_settings['key']
Pusher.secret = pusher_settings['secret']
Pusher.logger = $logger if $logger
