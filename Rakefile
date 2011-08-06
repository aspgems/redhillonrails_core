require 'pathname'
ENV["BUNDLE_GEMFILE"] ||= begin
                            version = if File.exist?("./.gemfile")
                                        File.read("./.gemfile").chomp
                                      else
                                        "rails-3.0.7"
                                      end
                            File.expand_path("../gemfiles/#{version}", __FILE__)
                          end
puts "Using gemfile: #{ENV["BUNDLE_GEMFILE"].gsub(Pathname.new(__FILE__).dirname.to_s,'').sub(/^\//,'')}"
require "bundler"
begin
  Bundler.setup
rescue
  if ENV["CI"]
    sh "bundle install"
    Bundler.setup
  else
    raise "You need to install a bundle first. Try 'thor gemfile:use 3.0.7'"
  end
end
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
%w[postgresql mysql mysql2 sqlite3].each do |adapter|
  namespace adapter do
    RSpec::Core::RakeTask.new(:spec) do |spec|
      spec.rspec_opts = "-Ispec/connections/#{adapter}"
    end
  end
end

task :default => [:create_databases, :spec]

desc 'Run postgresql and mysql tests'
task :spec do
  %w[postgresql mysql mysql2 sqlite3].each do |adapter|
    puts "\n\e[1;33m[#{ENV["BUNDLE_GEMFILE"]}] #{adapter}\e[m\n"
    Rake::Task["#{adapter}:spec"].invoke
  end
end

desc 'Create databases'
task :create_databases do
  %w[postgresql mysql].each do |adapter|
    Rake::Task["#{adapter}:build_databases"].invoke
  end
end

namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do
    system "psql -c 'create database redhillonrails_core;' -U postgres >/dev/null"
    abort "failed to create postgres database" unless $?.success?
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases do
    %x( dropdb rh_core_unittest )
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases do
    system "mysql -e 'create database redhillonrails_core default character set utf8 default collate utf8_unicode_ci;' >/dev/null"
    abort "failed to create mysql database" unless $?.success?
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases do
    %x( mysqladmin -f drop redhillonrails_core )
  end

  desc 'Rebuild the MySQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
  rm_rf "tmp"
  rm    "Gemfile.lock" if File.exist?("Gemfile.lock")
end

task :default => :spec