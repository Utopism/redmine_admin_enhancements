if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

# Smile specific #322539 Utilisation d'un nouveau champ *settable*
class AddRoleSettable < migration
  def self.up
    add_column :roles, :settable, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :roles, :settable
  end
end
