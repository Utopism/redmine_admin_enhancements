class AddJournalDetailsJournalIdPropKeyIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :journal_details, [:journal_id, :prop_key], :name => :journal_details_journal_id_prop_key
  end

  def self.down
    remove_index :journal_details, :journal_details_journal_id_prop_key
  end
end
