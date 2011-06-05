require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Command Recorder' do
  if defined?(ActiveRecord::Migration::CommandRecorder)
    before do
      @recorder = ActiveRecord::Migration::CommandRecorder.new
    end

    it 'invert_add_foreign_key' do
      @recorder.add_foreign_key(:employees, :companies)
      remove = @recorder.inverse.first
      remove.should == [:remove_foreign_key, [:employees, :companies]]
    end

    it 'invert_add_foreign_key with column' do
      @recorder.add_foreign_key(:employees, :companies, :column => :place_id)
      remove = @recorder.inverse.first
      remove.should == [:remove_foreign_key, [:employees, {:column => :place_id}]]
    end

    it 'invert_add_foreign_key with name' do
      @recorder.add_foreign_key(:employees, :companies, :name => 'the_best_fk', :column => :place_id)
      remove = @recorder.inverse.first
      remove.should == [:remove_foreign_key, [:employees, {:name => 'the_best_fk'}]]

      @recorder.record :rename_table, [:old, :new]
      rename = @recorder.inverse.first
      rename.should == [:rename_table, [:new, :old]]
    end

    it 'remove_foreign_key is irreversible' do
      @recorder.remove_foreign_key(:employees, :companies)
      expect {
        @recorder.inverse
      }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end

end