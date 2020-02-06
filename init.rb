# encoding: UTF-8

require 'redmine'

Rails.logger.info 'o=>'
Rails.logger.info 'o=>Starting Redmine Admin Enhancements plugin for RedMine'
Rails.logger.info "o=>Application user : #{ENV['USER']}"


plugin_root = File.dirname(__FILE__)

plugin_name = :redmine_admin_enhancements

Redmine::Plugin.register plugin_name do
  name 'Redmine - Admin - Enhancements'
  author 'Jérôme BATAILLE'
  author_url "mailto:Jerome BATAILLE <mail@jeromebataille.fr>?subject=#{plugin_name}"
  description 'Add enhancements in Administation backend (compatible with RM V2.6.10+)'
  url "https://github.com/Utopism/#{plugin_name}"
  version '1.0.003'
  requires_redmine :version_or_higher => '2.6.0'

  #Plugin home page
  settings :default => HashWithIndifferentAccess.new(
    ),
    :partial => "settings/#{plugin_name}"


  ##########################
  # 1.1/ Project permissions
  # Evolution #29527 Masquer la case "public" dans le formulaire de création de projets
  permission :add_public_project, {:projects => [:new, :create]}, :require => :loggedin

  # Evolution #367502 Création d'un projet à partir d'un template
  permission :copy_project, {:projects => [:copy]}, :require => :loggedin
  # END -- 1.2/ Modules permissions
  #################################
end

plugin_version    = '?.?'
plugin_id         = 0
plugin_rel_root   = '.' # Root relative to application root

this_plugin = Redmine::Plugin::find(plugin_name.to_s)
if this_plugin
  plugin_version  = this_plugin.version
  plugin_id       = this_plugin.__id__
  plugin_rel_root = 'plugins/' + this_plugin.id.to_s
end


def prepend_in(dest, mixin_module)
  return if dest.include? mixin_module

  # Rails.logger.info "o=>#{dest}.prepend #{mixin_module}"
  dest.send(:prepend, mixin_module)
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  rails_dispatcher = Dispatcher
else
  rails_dispatcher = Rails.configuration
end

# Executed after Rails initialization, each time the classes are reloaded
rails_dispatcher.to_prepare do
  Rails.logger.info "o=>"
  Rails.logger.info "o=>\\__ #{plugin_name} V#{plugin_version} id #{plugin_id}"

  # Id of each plugin method
  SmileTools.reset_override_count(plugin_name)

  SmileTools.trace_override "                                plugin  #{plugin_name} V#{plugin_version} id #{plugin_id}"

  ######################################
  # 3.1/ List of reloadable dependencies
  # To put here if we want recent source files reloaded
  # Outside of to_prepare, file changed => reloaded,
  # but with primary loaded source code, not the new one
  required = [
    # lib/
    "/lib/#{plugin_name}/hooks",

    # lib/controllers
    '/lib/controllers/smile_controllers_projects',
    '/lib/controllers/smile_controllers_admin',

    # lib/helpers
    '/lib/helpers/smile_helpers_queries',
    '/lib/helpers/smile_helpers_projects',

    # lib/models
    '/lib/models/smile_models_project',
    '/lib/models/smile_models_user',
    '/lib/models/smile_models_role',
    '/lib/models/smile_models_mailer',
    '/lib/models/smile_models_project_custom_field',
    '/lib/models/smile_models_tracker',
  ]


  ###############
  # 3.2/ Requires
  if Rails.env == "development"
    Rails.logger.debug "o=>require_dependency"
    required.each{ |d|
      Rails.logger.debug "o=>  #{plugin_rel_root + d}"
      # Reloaded each time modified
      require_dependency plugin_root + d
    }
    required = nil

    # Folders whose contents should be reloaded, NOT including sub-folders

#    ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(plugin_root)}/}

    # Paths to watch when file are changed
    Rails.logger.debug 'o=>'
    Rails.logger.debug "o=>autoload_paths / watchable_dirs +="
    ['/lib/controllers', '/lib/helpers', '/lib/models'].each{|p|
      new_path = plugin_root + p
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      ActiveSupport::Dependencies.autoload_paths << new_path
      rails_dispatcher.watchable_dirs[new_path] = [:rb]
    }
  else
    Rails.logger.debug "o=>require"
    required.each{ |p|
      # Never reloaded
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      require plugin_root + p
    }
  end
  # END -- Manage dependencies


  #######################
  # **** 3.3.1/ Libs ****

  # Smile::{Controllers, Models, Helpers}
  # Postfix sub-modules with Override to avoid a conflic with original classes / modules
  # Specially for Models
  # They are searched first at the parent namespace
  # Example Smile::Models::Issue instead of ::Issue

  Rails.logger.info "o=>----- LIBS"


  ##############################
  # **** 3.3.2/ Controllers ****
  Rails.logger.info "o=>----- CONTROLLERS"

  prepend_in(ProjectsController, Smile::Controllers::ProjectsOverride::CopyProjectPermission)
  prepend_in(ProjectsController, Smile::Controllers::ProjectsOverride::ActionsKeepFilters)

  prepend_in(AdminController, Smile::Controllers::AdminOverride::Enhancements)



  ##########################
  # **** 3.3.3/ Helpers ****
  Rails.logger.info "o=>----- HELPERS"
  # Sub-module still there if reloading
  # => Re-prepend each time

  prepend_in(ProjectsHelper, Smile::Helpers::ProjectsOverride::HideChildren)

  prepend_in(QueriesHelper, Smile::Helpers::QueriesOverride::RolesSettable)


  #########################
  # **** 3.3.4/ Models ****
  Rails.logger.info "o=>----- MODELS"

  prepend_in(Project, Smile::Models::ProjectOverride::ProjectCustomFieldEditionRole)

  unless Project.instance_methods.include?(:having_parent)
    prepend_in(Project, Smile::Models::ProjectOverride::NewScopes)
  end

  prepend_in(User, Smile::Models::UserOverride::MemberShipsWithArchivedProjects)

  # OK
  prepend_in(Role, Smile::Models::RoleOverride::ExcludeUnsettable)

  # OK
  prepend_in(Mailer, Smile::Models::MailerOverride::RedirectMailsToAuthor)

  # OK
  prepend_in(ProjectCustomField, Smile::Models::ProjectCustomFieldOverride::ProjectCustomFieldEditionRole)

  # OK
  prepend_in(Tracker, Smile::Models::TrackerOverride::MandatoryTracker)


  # keep traces if classes / modules are reloaded
  SmileTools.enable_traces(false, plugin_name)

  Rails.logger.info 'o=>/--'
end # rails_dispatcher.to_prepare do
