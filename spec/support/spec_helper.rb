require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rspec'
require File.expand_path('../../../lib/rdparser.rb', __FILE__)

Dir[File.expand_path('../**/*.rb', __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.alias_it_should_behave_like_to(:it_should_behave_like, '')
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end

