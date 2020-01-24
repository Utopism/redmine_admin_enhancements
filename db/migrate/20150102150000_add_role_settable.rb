# Smile specific #322539 Utilisation d'un nouveau champ *settable*
class AddRoleSettable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :roles, :settable, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :roles, :settable
  end
end
