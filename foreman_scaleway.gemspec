require File.expand_path('../lib/foreman_scaleway/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_scaleway'
  s.version     = ForemanScaleway::VERSION
  # rubocop:disable Date
  s.date        = Date.today.to_s
  # rubocop:enable Date
  s.authors     = ['Timo Goebel']
  s.email       = ['mail@timogoebel.name']
  s.homepage    = 'http://github.com/timogoebel/foreman_scaleway'
  s.summary     = 'Scaleway as a compute resource for Foreman'
  # also update locale/gemspec.rb
  s.description = 'Provision and manage Scaleway cloud servers from Foreman'
  s.licenses    = ['GPL-3.0']

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'fog-scaleway'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
end
