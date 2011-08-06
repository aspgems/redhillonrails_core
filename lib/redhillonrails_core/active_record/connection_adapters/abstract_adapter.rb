module RedhillonrailsCore::ActiveRecord::ConnectionAdapters
  module AbstractAdapter
    def self.included(base)
      base.module_eval do
        alias_method_chain :initialize, :redhillonrails_core
        alias_method_chain :drop_table, :redhillonrails_core
      end
    end

    def initialize_with_redhillonrails_core(*args)
      initialize_without_redhillonrails_core(*args)
      adapter = nil
      case adapter_name
        # name of MySQL adapter depends on mysql gem
        # * with mysql gem adapter is named MySQL
        # * with mysql2 gem adapter is named Mysql2
        # Here we handle this and hopefully futher adapter names
        when /^MySQL/i
          adapter = 'MysqlAdapter'
        when 'PostgreSQL'
          adapter = 'PostgresqlAdapter'
        when 'SQLite'
          adapter = 'Sqlite3Adapter'
      end
      if adapter
        adapter_module = RedhillonrailsCore::ActiveRecord::ConnectionAdapters.const_get(adapter)
        self.class.send(:include, adapter_module) unless self.class.include?(adapter_module)
      end
      # Mysql2 gem adds own Mysql2IndexDefinition in versions from 0.2.7 to 0.2.11.
      # We must include RedhillonrailsCore IndexDefinition to support case sensitivness.
      # 0.3 line of mysql2 removes it again so hopefully we'll remove that obsure piece of code too.
      if adapter_name =~ /^Mysql2/i && defined?(ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition)
        index_definition_module = RedhillonrailsCore::ActiveRecord::ConnectionAdapters::IndexDefinition
        unless ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition.include?(index_definition_module)
          ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition.send(:include, index_definition_module)
        end
      end
    end
    
    def create_view(view_name, definition)
      execute "CREATE VIEW #{view_name} AS #{definition}"
    end
    
    def drop_view(view_name)
      execute "DROP VIEW #{view_name}"
    end
    
    def views(name = nil)
      []
    end
    
    def view_definition(view_name, name = nil)
    end

    def foreign_keys(table_name, name = nil)
      []
    end

    def reverse_foreign_keys(table_name, name = nil)
      []
    end

    def add_foreign_key(table_name, column_names, references_table_name, references_column_names, options = {})
      foreign_key = ForeignKeyDefinition.new(options[:name], table_name, column_names, ActiveRecord::Migrator.proper_table_name(references_table_name), references_column_names, options[:on_update], options[:on_delete], options[:deferrable])
      execute "ALTER TABLE #{table_name} ADD #{foreign_key}"
    end

    def remove_foreign_key(table_name, foreign_key_name)
      execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{foreign_key_name}"
    end

    def drop_table_with_redhillonrails_core(name, options = {})
      reverse_foreign_keys(name).each do |foreign_key|
        begin
          remove_foreign_key(foreign_key.table_name, foreign_key.name)
        rescue Exception => e
          # TODO spec this
          #there is a problem when using rollback if two tables have 
          #similar names. In that case, the plugin will try to remove a
          #non-existing column and raise an exception. I rescue the
          #exception so the migration can proceed
          nil
        end  
      end
      drop_table_without_redhillonrails_core(name, options)
    end
  end
end
