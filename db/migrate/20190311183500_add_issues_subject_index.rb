class AddIssuesSubjectIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :issues, :subject
  end

  def self.down
    remove_index :issues, :subject
  end
end
