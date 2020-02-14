redmine_admin_enhancements
==========================


Redmine plugin that adds enhancements in Administation backend (compatible with RM V2.6.10+)

# What it does

* **Projects Administration** :

  * New columms If filter **Subproject** of is set (to avoid to many queries)

    These columns are useful to check before archiving / deleting a project

    * **Issues (open) / Members / Subprojects**
      * Issue count
      * Opened Issue count
      * Members count
      * Sub-projects count

    * **Subproject of**

  * Fixes links for *Archive* / *Unarchive* / *Delete* to **keep current filters**

* **Assignee** selection in **Issues context menu**
  * **Nobody** at the beginning

* Role-based Project custom field editability

  Allows to **restrict Project Custom Fields edition** to some roles

* New **mandatory** flag for **Trackers**

  These trackers can not be removed from the project configuration, once enabled

* Notifications option in plugin configuration : **redirect all notifications to the action author**

  Usefull for Testing servers having a dump of production data : avoid to send notifications to real users.

* Roles restriction

  Add a new *Settable* flag to Roles.
  When set, the role is only **givable by admins** or by **members of a group** specified in role configuration

# How it works

Overrides views to bring new features, to help Administrators managing Projects, Workflows, Roles, Users ...

* Views / Partials in **app/views** :
  * 🔑 Rewritten **admin/projects.html.erb**

    New filters and informations on projects

  * 🔑 Rewritten **context_menus/issues.html.erb**

    Assignee selection in Issues context menu : Nobody at the beginning

  * 🔑 Rewritten **custom_fields/_form.html.erb**

    * Issue Custom Field Edition : list of projects using the custom field

      Not full projects list, only the ones that have the custom field enabled, with parent projects.

    * Role-based Project custom field editability

      Allows to **restrict Project Custom Fields edition** to some roles

      This is the base to enable new features through a Custom Field that only some people can enable.

    * Custom Field edition : do not localize name if Localizable plugin is enabled

  * New **mandatory** flag for **Trackers** :

    * hooks/_view_project_settings_tracker_after_checkbox_mandatory.html.erb
    * hooks/_view_project_settings_tracker_before_checkbox_mandatory.html.erb
    * hooks/_view_projects_show_sidebar_bottom_empty_because_mandatory.html.erb

  * 🔑 Rewritten **issue_statuses/edit.html.erb**

    Issue Status edition : list of **roles using a specific status**, by role and tracker

  * 🔑 Rewritten **issue_statuses/index.html.erb**

    Issue Statuses list : Position value indication

  * Option in plugin configuration : **redirect all notifications to the action author** :
    * 🔑 Rewritten **layouts/mailer.html.erb**
    * New **mailer/_redirected_recipients.html.erb**

  * Add a new *Settable* flag to Roles to restrict some roles access.

    Roles only givable by admins or by the members of a group specified in the role configuration
    * 🔑 Rewritten **members/_edit.html.erb**
    * 🔑 Rewritten **members/_new_form.html.erb**
  * 🔑 Rewritten **principal_memberships/_index.html.erb**

    New param to show archived projects.

  * 🔑 Rewritten **projects/_form.html.erb**
    * Disable public project creation on a role basis
    * Role-based project custom field editability
  * 🔑 Rewritten **projects/copy.html.erb**

    Project copy : members replication not checked by default

  * 🔑 Rewritten **projects/destroy.html.erb**

    Keep params added in projects index

  * 🔑 Rewritten **projects/show.html.erb**
    * Copy project link on Project show
    * + **Id** and **Last update date** fields
  * 🔑 Rewritten **projects/settings/_members.html.erb**

    Members roles : display group of role

  * 🔑 Rewritten **roles/_form.html.erb**

    Add a new *Settable* flag to Roles to restrict some roles access.

  *  List of projects members having this role
    * New **roles/_members.html.erb**
    * New **roles/_projects.html.erb**
    * 🔑 Rewritten **roles/edit.html.erb**
  * 🔑 Rewritten **roles/index.html.erb**

    Add a new *Settable* flag to Roles to restrict some roles access.

  * 🔑 Rewritten **roles/permissions.html.erb**

    Link on group permissions to show only the permissions of this group

  * New **settings/_redmine_admin_enhancements.html.erb**

    Option in plugin configuration : **redirect all notifications to the action author**

  * 🔑 Rewritten **trackers/_form.html.erb**
    * Add a new mandatory flag to the trackers
    * Flag to show only projects having tracker enabled
    * Tracker edition : link to project

  * 🔑 Rewritten **trackers/index.html.erb**
    * Add a new mandatory flag to the trackers

  * 🔑 Rewritten **users/_groups.html.erb**

    User groups : show only the groups the user is member of with parameter **only_member**

  * 🔑 Rewritten **users/mail_notifications.html.erb**

    Added link to projects

  * 🔑 Rewritten **users/show.html.erb**

    * Display user API key for Administrators only

  * 🔑 Rewritten **workflows/_form.html.erb**
    **Only display statuses that are used by this tracker** : removes more columns and lines with no status enabled

  * 🔑 Rewritten **workflows/copy.html.erb**

    Workflow copy : Destination Tracker/Role select with 10 lines instead of 4

* **Overrides** in lib/
  * **controllers**
    * smile_controllers_admin
      * 🔑 Rewritten method **projects**

        Show issues count

    * smile_controllers_projects
      * New permission **can_copy_project**
      * 🔑 Rewritten method **archive**
      * 🔑 Rewritten method **unarchive**
      * 🔑 Rewritten method **destroy**

  * **helpers**
    * smile_helpers_projects
      * 🔑 Rewritten method **render_project_hierarchy**
    * smile_helpers_queries
    * New method **roles_settable_hook**

  * **models**
    * **smile_models_mailer**
      * 🔑 Rewritten method **mail**
      * 🔑 Rewritten class method **email_addresses**
    * **smile_models_project**
      * New method **editable_custom_field_values**
      * 🔑 Extended **safe_attributes=**
      * New scope **having_parent**

    * **smile_models_project_custom_field**
      * New method **editable_by?**
      * New method **bool_custom_value_set_on=**
      * New method **reset_available_custom_fields**

    * **smile_models_role**
      * New method **unsettable_exception_group**
      * New method **visible?**
      * New class method **exclude_unsettable**
      * New class method **only_unsettable**
      * New safe attribute **settable**
      * New safe attribute **unsettable_exception_groupname**

    * **smile_models_tracker**
      * New safe attribute **mandatory**

    * **smile_models_user**
      * New has_many **memberships_all**

        User memberships, params to show archived projects

* New hooks in **hooks/redmine_admin_enhancements** for
  New **mandatory** flag for **Trackers**

  * On **view_projects_show_sidebar_bottom**
    view_projects_show_sidebar_bottom_empty_because_mandatory
  * On **view_project_settings_tracker_before_checkbox**
    view_project_settings_tracker_before_checkbox_mandatory
  * On **view_project_settings_tracker_after_checkbox**
    view_project_settings_tracker_after_checkbox_mandatory

* New permissions :
  * **add_public_project**
  * **copy_project**

* New task to fix problems with issues trees :

  **smile_tools_tree.rake**
  * Repair ciruclar references of issues (params : root_id, dry_run)
  * Get issue's children (params : issue_id, sort)
  * Detect wrong root_id compared to parent_id

 * New **migrations** :
   * 20121011130000_add_tracker_mandatory
   * 20150102150000_add_role_settable
   * 20190311183500_add_issues_subject_index
   * 20190503170000_add_role_unsettable_exception_groupname.rb
   * 20191102224500_add_journal_details_journal_id_prop_key_index

# **TODOs**

* Enable expander css for projects/index action
* Get translation label_id
* Get unsettable css

# Changelog

* **V1.0.003**  Compatibility of migrations with Rails < 4.2

