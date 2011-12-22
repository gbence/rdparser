require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'

require 'rake/packagetask'
require 'rubygems/package_task'

RDPARSER_GEMSPEC = eval(File.read(File.expand_path("../rdparser.gemspec", __FILE__)))

desc 'Default: run specs'
task :default => 'spec'

namespace :spec do
  desc 'Run all specs in spec directory (format=progress)'
  RSpec::Core::RakeTask.new(:progress) do |t|
    t.pattern = './spec/**/*_spec.rb'
    t.rspec_opts = ['--color', '--format=progress']
  end

  desc 'Run all specs in spec directory (format=documentation)'
  RSpec::Core::RakeTask.new(:documentation) do |t|
    t.pattern = './spec/**/*_spec.rb'
    t.rspec_opts = ['--color', '--format=documentation']
  end
end

task :spec => 'spec:progress'

desc 'Generate documentation for the rdparser plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RDParser'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  #rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Gem::PackageTask.new(RDPARSER_GEMSPEC) do |p|
  p.gem_spec = RDPARSER_GEMSPEC
end
