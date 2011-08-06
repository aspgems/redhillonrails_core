module RedhillonrailsCore::ActiveRecord::ConnectionAdapters
	module IndexDefinition
    # Using accessors in postgresql
    attr_accessor :conditions, :expression, :kind

		def case_sensitive?
			@case_sensitive.nil? ? true : @case_sensitive
		end

		def case_sensitive=(case_sensitive)
			@case_sensitive = case_sensitive
		end
	end
end
