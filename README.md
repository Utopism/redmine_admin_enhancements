redmine_admin_enhancements
==========================


Redmine plugin that adds enhancements in Administation backend (compatible with RM V2.6.10+)

# What it does

## **Projects Administration** :

* New columms in **Project list** page if filter **Subproject** of is set (to avoid to many queries)

  These columns are useful to make some checks before **(Un-)Archiving / Deleting** a project :

  * **Issues (open) / Members / Subprojects**, this column includes :
    * Issue count
    * Opened Issue count
    * Members count
    * Sub-projects count

  * **Subproject of**

* Fixes links for *Archive* / *Unarchive* / *Delete* to **keep current filters**

## **Custom Fields Administration** : Role-based **Project custom field** editability

Allows to **restrict Project Custom Fields edition** to some roles

## **Trackers Administration** : new **Mandatory** flag

These trackers set as mandatory once enabled **can not be unchecked** in the **Project configuration** (except by Administrators)

## **Roles Administration** : role access restriction

Add a new **Settable** flag to Roles.
When set, the role is only **givable by admins** or by **members of a group** specified in role configuration.
Un-settable Roles set on members in projects before the role was set unsettable stay as is.

You can use css in your **Redmine themes** to emphasis these unsettable roles, in **projects members configuration**.

* For example :
```css
.unsettable {
  color: #eb3664;
  font-style: italic;
}
```

## Notifications option in plugin configuration : **redirect all notifications to the action author**

Usefull for Testing servers having a dump of production data : avoid to send notifications to real users.
Notifications will be redirected to the User that as made the modification.

## **Issues context menu**, present on right click in each Issues table list

* **Assignee** selection : **Nobody** at the beginning


# How it works

## 1/ Overrides Views / Partials in **app/views**

To bring new features, to help Administrators managing Projects, Workflows, Roles, Users ...

* 🔑 REWRITTEN **admin/projects.html.erb**

  New filters and informations on projects

* 🔑 REWRITTEN **context_menus/issues.html.erb**

  Assignee selection in Issues context menu : **Nobody** at the beginning

* 🔑 REWRITTEN **custom_fields/_form.html.erb**

  * Issue Custom Field Edition : new filtered list of **projects using the custom field**

    Not full projects list, only the ones that **have the custom field enabled**, including parent projects to see the projects tree.

  * Role-based Project custom field editability

    Allows to **restrict Project Custom Fields edition** to some roles

    This is the base to **enable new features through a Custom Field** that **only some people can enable**.

  * Custom Field edition : do not localize name if **Localizable plugin** is enabled

* New **mandatory** flag for **Trackers** :

  * hooks/_view_project_settings_tracker_after_checkbox_mandatory.html.erb
  * hooks/_view_project_settings_tracker_before_checkbox_mandatory.html.erb
  * hooks/_view_projects_show_sidebar_bottom_empty_because_mandatory.html.erb

* 🔑 REWRITTEN **issue_statuses/edit.html.erb**

  Issue Status edition : list of **roles using a specific status**, by role and tracker

* 🔑 REWRITTEN **issue_statuses/index.html.erb**

  Issue Statuses list : new Status position column

* Option in plugin configuration : **redirect all notifications to the action author** :
  * 🔑 REWRITTEN **layouts/mailer.html.erb**
  * New **mailer/_redirected_recipients.html.erb**

* Add a new **Settable** flag to Roles to restrict some roles access.

  Roles only givable by admins or by the members of a group specified in the role configuration
  * 🔑 REWRITTEN **members/_edit.html.erb**
  * 🔑 REWRITTEN **members/_new_form.html.erb**
* 🔑 REWRITTEN **principal_memberships/_index.html.erb**

  New param to **show archived projects**, that are normally hidden.

* 🔑 REWRITTEN **projects/_form.html.erb**
  * Disable public project creation on a role basis
  * Role-based project custom field editability
* 🔑 REWRITTEN **projects/copy.html.erb**

  Project copy : members replication not checked by default

* 🔑 REWRITTEN **projects/destroy.html.erb**

  Keep params added in projects index (filter on Sub-project, etc.)

* 🔑 REWRITTEN **projects/show.html.erb**
  * Copy project link on Project show
  * + **Id** and **Last update date** fields
* 🔑 REWRITTEN **projects/settings/_members.html.erb**

  Members roles : **display group of role**

* 🔑 REWRITTEN **roles/_form.html.erb**

  Add a new **Settable** flag to Roles to restrict some roles access.

*  List of projects members having this role
  * New **roles/_members.html.erb**
  * New **roles/_projects.html.erb**
  * 🔑 REWRITTEN **roles/edit.html.erb**
* 🔑 REWRITTEN **roles/index.html.erb**

  Add a new **Settable** flag to Roles to restrict some roles access.

* 🔑 REWRITTEN **roles/permissions.html.erb**

  Link on group permissions to filter permissions to **show only the permissions of this group**

* New **settings/_redmine_admin_enhancements.html.erb**

  Option in plugin configuration : **redirect all notifications to the action author**

* 🔑 REWRITTEN **trackers/_form.html.erb**
  * Add a new mandatory flag to the trackers
  * Flag to show only projects having tracker enabled
  * Tracker edition : link to project

* 🔑 REWRITTEN **trackers/index.html.erb**
  * Add a new mandatory flag to the trackers

* 🔑 REWRITTEN **users/_groups.html.erb**

  User groups : show only the groups the user is member of with parameter **only_member**

* 🔑 REWRITTEN **users/mail_notifications.html.erb**

  Added link to projects

* 🔑 REWRITTEN **users/show.html.erb**

  * Display **user API key** for Administrators only

* 🔑 REWRITTEN **workflows/_form.html.erb**

  **Only display statuses that are used by this tracker** : removes more columns and lines with no status enabled

* 🔑 REWRITTEN **workflows/copy.html.erb**

  Workflow copy : Destination Tracker/Role select with **10 lines** instead of 4

## 2/ **Overrides** in lib/

* **controllers**
  * smile_controllers_admin
    * 🔑 REWRITTEN method **projects**

      Prepare issues count for view.

  * smile_controllers_projects
    * New permission **can_copy_project**
    * To **use / keep** in Url redirection **new filters** added in Projects Administration list :
      * 🔑 REWRITTEN method **archive**
      * 🔑 REWRITTEN method **unarchive**
      * 🔑 REWRITTEN method **destroy**

* **helpers**
  * smile_helpers_projects
    * 🔑 REWRITTEN method **render_project_hierarchy**

    Links to **hide / show sub-projects**

  * smile_helpers_queries
    * New method **roles_settable_hook**

* **models**
  * **smile_models_mailer** to allow **redirect all notifications to the action author** :
    * 🔑 REWRITTEN method **mail**
    * 🔑 REWRITTEN class method **email_addresses**
  * **smile_models_project**
    * New method **editable_custom_field_values**
    * **Extended** **safe_attributes=**
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

## 3/ New hooks in **hooks/redmine_admin_enhancements** :

New **mandatory** flag for **Trackers**

* On **view_projects_show_sidebar_bottom**
  view_projects_show_sidebar_bottom_empty_because_mandatory
* On **view_project_settings_tracker_before_checkbox**
  view_project_settings_tracker_before_checkbox_mandatory
* On **view_project_settings_tracker_after_checkbox**
  view_project_settings_tracker_after_checkbox_mandatory

## 4/ New permissions :

* **add_public_project**
* **copy_project**

## 5/ New task to fix problems with issues trees :

**smile_tools_tree.rake** :
* Repair ciruclar references of issues (params : root_id, dry_run)
* Get issue's children (params : issue_id, sort)
* Detect wrong root_id compared to parent_id

## 6/ New **migrations** :

* 20121011130000_add_tracker_mandatory
* 20150102150000_add_role_settable
* 20190311183500_add_issues_subject_index
* 20190503170000_add_role_unsettable_exception_groupname.rb
* 20191102224500_add_journal_details_journal_id_prop_key_index

# **TODOs**

* Plugin option to redirect all notifications to the action author

  TODO use hook, when RM #11530 Support hooks in mailer is delivered (V4.1)

* Translate **permission_add_public_project** for ca(talan) language

* Role-based project custom field editability : Manage **Relay role** in **editable_by?**

  Specific to other plugins using this one.

# Changelog

* **V1.0.004**  Old TODOs fixed

  + translation label_id, + expander header css link for **projects/index** action

* **V1.0.003**  Compatibility of migrations with Rails < 4.2
