module RedHillConsulting::Core::ActiveRecord::ConnectionAdapters
	module Column

	  def required_on
	    if null
	      nil
	    elsif default.nil?
	      :save
	    else
	      :update
	    end
	  end
	end
end
