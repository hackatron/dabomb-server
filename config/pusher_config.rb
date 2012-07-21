if 'production' == ENV['RACK_ENV']
  pusher_settings = {
    'app_id' => ENV['PUSHER_API_ID'],
    'key'    => ENV['PUSHER_KEY'],
    'secret' => ENV['PUSHER_SECRET']
  }
else
  dir = File.expand_path(File.dirname(__FILE__))
  pusher_config = File.new(dir + "/pusher.yml").read
  pusher_settings = YAML::load(pusher_config)
end

Pusher.app_id = pusher_settings['app_id']
Pusher.key    = pusher_settings['key']
Pusher.secret = pusher_settings['secret']
Pusher.logger = $logger if $logger
