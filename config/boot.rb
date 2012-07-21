ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# setting-up the LOAD_PATH
$:.unshift(File.join(File.dirname(__FILE__), '/../'))

require 'logger'
require 'da_bomb'
