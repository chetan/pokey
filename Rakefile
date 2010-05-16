
begin
    require 'rubygems'
    require 'jeweler'
rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install jeweler"
    err = 1
end

begin
    require "yard"
rescue LoadError
    puts "YARD not available. Install it with: sudo gem install yard"
    err = 1
end

exit if err

Jeweler::Tasks.new do |gemspec|
    gemspec.name = "pokey"
    gemspec.summary = "Ruby library for handling Poker game mechanics"
    gemspec.description = ""
    gemspec.email = "chetan@pixelcop.net"
    gemspec.homepage = "http://github.com/chetan/pokey"
    gemspec.authors = ["Chetan Sarva"]
    # gemspec.add_dependency('scrapi', '>= 1.2.0')
    # gemspec.add_dependency('tzinfo', '>= 0.3.15')
end
Jeweler::GemcutterTasks.new

require "rake/testtask"
desc "Run unit tests"
Rake::TestTask.new("test") do |t|
    #t.libs << "test"
    t.ruby_opts << "-rubygems"
    t.pattern = "test/**/*_test.rb"
    t.verbose = false
    t.warning = false
end

YARD::Rake::YardocTask.new("docs") do |t|
    
end