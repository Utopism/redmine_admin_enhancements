if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class AddTrackerMandatory < migration
  def self.up
    add_column :trackers, :mandatory, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :trackers, :mandatory
  end
end
