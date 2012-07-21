ENV['RACK_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'support/da_bomb_support'

if ENV['DEBUG']
  Debugger.start
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include DaBombSupport
end
