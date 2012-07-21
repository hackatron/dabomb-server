require 'rspec/core/rake_task'

desc "Run a console for the App"
task :console do
  puts "Loading console..."
  system("irb -r ./config/boot.rb")
end

task :default => :spec

desc "Run specs"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = './spec/**/*_spec.rb'
  end
end