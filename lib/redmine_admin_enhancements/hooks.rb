# This module name must be unique, if not the last Hooks class will be taken in account
module RedmineAdminEnhancementsPlugin
  class Hooks < Redmine::Hook::ViewListener
    # This just renders the partial in
    # app/views/hooks/my_plugin/_view_projects_show_sidebar_bottom.html.erb
    # The contents of the context hash is made available as local variables to the partial.
    #
    # Additional context fields
    #   :issue  => the issue this is edited
    #   :f      => the form object to create additional fields

    plugin_folder = 'redmine_admin_enhancements'

    # Smile specific : added because at least a hook render must exist
    # Smile specific : Used in sub-plugin
    render_on :view_projects_show_sidebar_bottom,
              :partial => "hooks/#{plugin_folder}/view_projects_show_sidebar_bottom_empty_because_mandatory"

    # Smile specific #781209 V4.0.0 : Project trackers setting : ability to remove mandatory tracker for admins
    render_on :view_project_settings_tracker_before_checkbox,
              :partial => "hooks/#{plugin_folder}/view_project_settings_tracker_before_checkbox_mandatory"

    render_on :view_project_settings_tracker_after_checkbox,
              :partial => "hooks/#{plugin_folder}/view_project_settings_tracker_after_checkbox_mandatory"
  end
end
