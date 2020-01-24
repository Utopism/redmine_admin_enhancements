class AddTrackerMandatory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :trackers, :mandatory, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :trackers, :mandatory
  end
end
