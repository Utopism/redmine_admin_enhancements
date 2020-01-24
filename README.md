redmine_admin_enhancements
==========================


Redmine plugin that adds enhancements in Administation backend (compatible with RM V2.6.10+)

# How it works

Overrides views to bring new features, to help Administrators managing Projects, Workflows, Roles, Users ...

* Views / Partials in **app/views** :
  * 🔑 Rewritten **admin/projects.html.erb**
  * 🔑 Rewritten **context_menus/issues.html.erb**
  * 🔑 Rewritten **custom_fields/_form.html.erb**
    TODO get unsettable css
  * 🔑 Rewritten **issue_statuses/edit.html.erb**
  * 🔑 Rewritten **issue_statuses/index.html.erb**
  * 🔑 Rewritten **admin/projects.html.erb**
  * 🔑 Rewritten **layouts/mailer.html.erb**
  * New **mailer/_redirected_recipients.html.erb**
  * 🔑 Rewritten **members/_edit.html.erb**
  * 🔑 Rewritten **members/_new_form.html.erb**
  * 🔑 Rewritten **principal_memberships/_index.html.erb**
  * 🔑 Rewritten **projects/_form.html.erb**
  * 🔑 Rewritten **projects/copy.html.erb**
  * 🔑 Rewritten **projects/show.html.erb**
       TODO get translation label_id
  * 🔑 Rewritten **projects/settings/_members.html.erb**
  * 🔑 Rewritten **roles/_form.html.erb**
  * New **roles/_members.html.erb**
  * New **roles/_projects.html.erb**
  * 🔑 Rewritten **roles/edit.html.erb**
  * 🔑 Rewritten **roles/index.html.erb**
  * 🔑 Rewritten **roles/permissions.html.erb**
  * New **settings/_redmine_admin_enhancements.html.erb**
  * 🔑 Rewritten **trackers/_form.html.erb**
  * 🔑 Rewritten **trackers/index.html.erb**
  * 🔑 Rewritten **users/_groups.html.erb**
  * 🔑 Rewritten **users/mail_notifications.html.erb**
  * 🔑 Rewritten **users/show.html.erb**
  * 🔑 Rewritten **workflows/_form.html.erb**
  * 🔑 Rewritten **workflows/copy.html.erb**

TODO get expander css

* New hooks in **hooks/redmine_admin_enhancements** :

  * **_view_project_settings_tracker_after_checkbox_mandatory.html.erb**
  * **_view_project_settings_tracker_before_checkbox_mandatory.html.erb**

* New permissions :
  * **add_public_project**
  * **copy_project**

* New task to fix problems with issues trees :

  **smile_tools_tree.rake**
  * Repair ciruclar references of issues (params : root_id, dry_run)
  * Get issue's children (params : issue_id, sort)
  * Detect wrong root_id compared to parent_id

## What it does

* **Projects Administration** :

  * New columms If filter **Subproject** of is set (to avoid to many queries)

    These columns are useful to check before archiving / deleting a project

    * **Issues (open) / Members / Subprojects**
      * Issue count
      * Opened Issue count
      * Members count
      * Sub-projects count

    * **Subproject of**

  * Fixes links for Archive / Unarchive to **keep current Subproject of filter**


