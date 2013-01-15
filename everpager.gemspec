# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'everpager/version'
require 'everpager/about'

Gem::Specification.new do |s|
  s.name                      = Everpager::ME.to_s
  s.version                   = Everpager::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = "Gerardo López-Fernádez"
  s.email                     = 'gerir@evernote.com'
  s.homepage                  = 'https://evernote.jira.com/wiki/display/OPS/everpager'
  s.summary                   = "Utility and library wrapper for Pagerduty"
  s.description               = "Everpager is a small utility and library wrapper for Pagerduty."
  s.license                   = "Internal use only"
  s.required_rubygems_version = ">= 1.3.5"

  s.add_dependency('inifile')
  s.add_dependency('rest-client')

  s.files        = Dir['lib/**/*.rb'] + Dir['bin/*'] + %w(LICENSE README.md)
  s.executables  = Dir['bin/*'].map { |entry| entry.gsub('bin/','') }
  s.require_path = 'lib'
end
