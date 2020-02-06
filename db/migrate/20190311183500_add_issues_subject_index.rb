if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class AddIssuesSubjectIndex < migration
  def self.up
    add_index :issues, :subject
  end

  def self.down
    remove_index :issues, :subject
  end
end
