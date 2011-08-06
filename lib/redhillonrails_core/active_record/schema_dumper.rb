module RedhillonrailsCore::ActiveRecord
  module SchemaDumper
    def self.included(base)
      base.class_eval do
        private
        alias_method_chain :tables, :redhillonrails_core
        alias_method_chain :indexes, :redhillonrails_core
      end
    end

    private

    def tables_with_redhillonrails_core(stream)
      @foreign_keys = StringIO.new
      begin
        tables_without_redhillonrails_core(stream)
        @foreign_keys.rewind
        stream.print @foreign_keys.read
        views(stream)
      ensure
        @foreign_keys = nil
      end
    end

    def indexes_with_redhillonrails_core(table, stream)
      if (indexes = @connection.indexes(table)).any?
        add_index_statements = indexes.map do |index|

          if index.columns.any?
            statement_parts = [('add_index ' + index.table.inspect)]
            statement_parts << index.columns.inspect
            statement_parts << (':name => ' + index.name.inspect)
            statement_parts << ':unique => true' if index.unique
            # This only used in postgresql - :case_sensitive, :conditions, :kind, :expression
            statement_parts << ':case_sensitive => false' unless index.case_sensitive?
            statement_parts << ':conditions => ' + index.conditions.inspect unless index.conditions.blank?
            statement_parts << ':kind => ' + index.kind.inspect unless index.kind.blank?
            statement_parts << ':expression => ' + index.expression.inspect unless index.expression.blank?
          else
            # This only used in postgresql - :case_sensitive, :conditions, :kind, :expression
            statement_parts = [('add_index ' + index.table.inspect)]
            statement_parts << (':name => ' + index.name.inspect)
            statement_parts << ':kind => ' + index.kind.inspect unless index.kind.blank?
            statement_parts << ':expression => ' + index.expression.inspect unless index.expression.blank?
          end

          if index.respond_to?(:lengths)
            index_lengths = index.lengths.compact if index.lengths.is_a?(Array)
            statement_parts << (':length => ' + Hash[*index.columns.zip(index.lengths).flatten].inspect) if index_lengths.present?
          end

          '  ' + statement_parts.join(', ')
        end

        stream.puts add_index_statements.sort.join("\n")
        stream.puts
      end

      foreign_keys(table, @foreign_keys)
    end

    def foreign_keys(table, stream)
      foreign_keys = @connection.foreign_keys(table)

      foreign_keys.sort! do |a, b|
        a.column_names.sort <=> b.column_names.sort
      end

      foreign_keys.each do |foreign_key|
        stream.print "  "
        stream.print foreign_key.to_dump
        stream.puts
      end
      stream.puts unless foreign_keys.empty?
    end
    
    def views(stream)
      views = @connection.views
      views.each do |view_name|
        definition = @connection.view_definition(view_name)
        stream.print "  create_view #{view_name.inspect}, #{definition.inspect}"
        stream.puts
      end
      stream.puts unless views.empty?
    end
  end
end
