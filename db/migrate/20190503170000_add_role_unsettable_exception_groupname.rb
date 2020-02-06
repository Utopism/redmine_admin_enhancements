if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class AddRoleUnsettableExceptionGroupname < migration
  def self.up
    add_column :roles, :unsettable_exception_groupname, :string, :null => true, :limit => 60
  end

  def self.down
    remove_column :roles, :unsettable_exception_groupname
  end
end
