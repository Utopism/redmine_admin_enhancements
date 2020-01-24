if Redmine::VERSION::MAJOR < 4
  migration = ActiveRecord::Migration
else
  migration = ActiveRecord::Migration[4.2]
end

class FixMigrationsNames < migration
  def self.up
    execute "update schema_migrations set version='20121011130000-redmine_admin_enhancements' where version='20121011130000-redmine_smile_enhancements'"
    execute "update schema_migrations set version='20150102150000-redmine_admin_enhancements' where version='20150102150000-redmine_smile_enhancements'"
    execute "update schema_migrations set version='20190311183500-redmine_admin_enhancements' where version='20190311183500-redmine_smile_enhancements'"
    execute "update schema_migrations set version='20190503170000-redmine_admin_enhancements' where version='20190503170000-redmine_smile_enhancements'"
    execute "update schema_migrations set version='20191102224500-redmine_admin_enhancements' where version='20191102224500-redmine_smile_enhancements'"

    say "5 migrations have changed of plugin, if you get an error, re-execute plugins migrations a second time, because old migration names are stored in memory cache"

    # Reload schema_migrations to refresh moved migration names -- does not work
    #User.connection.schema_cache.clear!
    #User.reset_column_information
  end

  def self.down
  end
end
