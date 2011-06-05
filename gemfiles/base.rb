module GemfileBase
  def self.extended(host)
    host.instance_eval do
      source "http://rubygems.org"

      gem 'rake', '0.9.1'
      gem 'rspec', '~> 2.5.0'
    end
  end
end