#require 'active_record/migration'
require 'active_support/core_ext/module/attribute_accessors'

module RedhillonrailsCore
  mattr_accessor :loaded_into_rails_core

  module ActiveRecord
    autoload :Base, 'redhillonrails_core/active_record/base'
    autoload :Schema, 'redhillonrails_core/active_record/schema'
    autoload :SchemaDumper, 'redhillonrails_core/active_record/schema_dumper'

    module ConnectionAdapters
      autoload :IndexDefinition, 'redhillonrails_core/active_record/connection_adapters/index_definition'
      autoload :TableDefinition, 'redhillonrails_core/active_record/connection_adapters/table_definition'
      autoload :Column, 'redhillonrails_core/active_record/connection_adapters/column'
      autoload :AbstractAdapter, 'redhillonrails_core/active_record/connection_adapters/abstract_adapter'
      autoload :SchemaStatements, 'redhillonrails_core/active_record/connection_adapters/schema_statements'

      autoload :ForeignKeyDefinition, 'redhillonrails_core/active_record/connection_adapters/foreign_key_definition'

      autoload :MysqlColumn, 'redhillonrails_core/active_record/connection_adapters/mysql_column'

      # Used in specs
      autoload :PostgresqlAdapter, 'redhillonrails_core/active_record/connection_adapters/postgresql_adapter'
      autoload :MysqlAdapter, 'redhillonrails_core/active_record/connection_adapters/mysql_adapter'
      autoload :Sqlite3Adapter, 'redhillonrails_core/active_record/connection_adapters/sqlite3_adapter'
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

    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) then
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::PostgresqlAdapter)
    end
    if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) then
      # TODO
      puts "include MysqlAdapter"
      #ActiveRecord::ConnectionAdapters::MysqlColumn.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::MysqlColumn)
      #ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::MysqlAdapter)
    end
    if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) then
      #ActiveRecord::ConnectionAdapters::Mysql2Column.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::MysqlColumn)
      #ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::MysqlAdapter)
      if defined?(ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition) then
        puts "include Mysql2IndexDefinition"
        ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::IndexDefinition)
      end
    end
    if defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) then
      #ActiveRecord::ConnectionAdapters::SQLite3Adapter.send(:include, RedhillonrailsCore::ActiveRecord::ConnectionAdapters::Sqlite3Adapter)
    end

    self.loaded_into_rails_core = true
  end
end

