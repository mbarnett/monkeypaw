#! /usr/bin/env ruby

require 'thor'

class MonkeyPaw < Thor
  include Thor::Actions

  desc "rack", "Creates a new Rack middleware project"
  def rack(name)
    empty_directory "rack-#{name}"

    inside "rack-#{name}" do
      empty_directory 'lib'

      create_file '.gitignore' do
        dot_gitignore
      end

      inside 'lib' do
        create_file "rack-#{name}.rb" do
          rack_toplevel(name)
        end
        empty_directory 'rack'
        inside 'rack' do
          empty_directory name
          inside name do
            create_file 'version.rb' do
              rack_version_rb(name)
            end
          end
          create_file "#{name}.rb" do
            rack_main(name)
          end
        end
      end

      empty_directory 'spec'

      create_file 'Rakefile' do
        rakefile
      end

      create_file 'README.md'
      create_file 'LICENSE'
      create_file 'Gemfile' do
        gemfile
      end
      create_file 'VERSION' do
        version
      end
      create_file "rack-#{name}.gemspec" do
        gemspec(name)
      end

      run 'git init'
    end
  end

no_commands {
def rack_toplevel(name)
<<-RACK_TOPLEVEL
require 'rack/#{name}'
RACK_TOPLEVEL
end

def rack_version_rb(name)
<<-VERSION_RB
module Rack
  class #{name.capitalize}
    VERSION = File.read File.join(File.expand_path("..", __FILE__), "..", "..", "..", "VERSION")
  end
end
VERSION_RB
end

def rack_main(name)
<<-RACK_MAIN
module Rack
  autoload :VERSION, 'rack/#{name}/version'

  DEFAULTS = {}

  class #{name.capitalize}
    def initialize(app, options={})
      DEFAULTS.merge(options)
      @app = app
    end

    def call(env)
      @status, @headers, @body = @app.call(env)

      # simple pass-through
      return [@status, @headers, @body]
    end
  end
end
RACK_MAIN
end

def gemfile
<<-GEMFILE
source "http://rubygems.org"

gemspec

group :development do
  gem 'rake'
end
GEMFILE
end

def dot_gitignore
<<-DOT_GITIGNORE
.DS_Store
pkg
*.gem
.bundle
DOT_GITIGNORE
end

def version
<<-VERSION
0.0.1
VERSION
end

def gemspec(name)
<<-GEMSPEC
require 'date'

Gem::Specification.new do |s|
  s.name = 'rack-#{name}'
  s.version = File.read('VERSION')

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fakey McFakerson"]
  s.date = Date.today.to_s
  s.description = %q{A rack middleware for <insert description here>}
  s.summary = %q{A rack middleware for <insert summary>}
  s.email = %q{fake@example.com}
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "Gemfile",
    "lib/rack-#{name}.rb",
    "lib/rack/#{name}.rb",
    "lib/rack/#{name}/version.rb",
    "rack-#{name}.gemspec"
  ]
  s.homepage = %q{}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{}
  s.rubygems_version = %q{1.3.7}
  s.test_files = [
  ]

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rack'

  if s.respond_to? :specification_version then
    s.specification_version = 3
  end
end
GEMSPEC
end

def rakefile
<<-RAKEFILE
require 'bundler'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
RAKEFILE
end

}

end

MonkeyPaw.start