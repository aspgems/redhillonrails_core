#require 'active_record/migration'
require 'active_record'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/attribute_accessors'

module RedhillonrailsCore
  mattr_accessor :loaded_into_rails_core

  module ActiveRecord
    extend ActiveSupport::Autoload

    module Migration
      extend ActiveSupport::Autoload

      autoload :CommandRecorder
    end

    autoload :Base
    autoload :Schema
    autoload :SchemaDumper

    module ConnectionAdapters
      extend ActiveSupport::Autoload

      autoload_under 'abstract' do
        autoload :IndexDefinition
        autoload :TableDefinition
        autoload :Column
        autoload :ForeignKeyDefinition
        autoload :SchemaStatements
      end

      autoload :AbstractAdapter
      autoload :PostgresqlAdapter
      autoload :MysqlAdapter
      autoload :MysqlColumn
      autoload :Sqlite3Adapter
    end
  end

  unless loaded_into_rails_core
    ::ActiveRecord::Base.send(:include, RedhillonrailsCore::ActiveRecord::Base)
    ::ActiveRecord::Schema.send(:include, RedhillonrailsCore::ActiveRecord::Schema)
    ::ActiveRecord::SchemaDumper.send(:include, RedhillonrailsCore::ActiveRecord::SchemaDumper)
    ::ActiveRecord::ConnectionAdapters::IndexDefinition.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::IndexDefinition)
    ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::TableDefinition)
    ::ActiveRecord::ConnectionAdapters::Column.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::Column)
    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::AbstractAdapter)
    ::ActiveRecord::ConnectionAdapters::SchemaStatements.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::SchemaStatements)

    if defined?(::ActiveRecord::Migration::CommandRecorder)
      ::ActiveRecord::Migration::CommandRecorder.class_eval do
        include RedhillonrailsCore::ActiveRecord::Migration::CommandRecorder
      end
    end

    self.loaded_into_rails_core = true
  end
end

