# Smile - override methods to the Projects controller
#
#
# 1/ module CopyProjectPermission
# * InstanceMethods
#   #367502 Création d'un projet à partir d'un template
#   2015/06
#
# 2/ module ActionsKeepFilters
# * InstanceMethods
#   #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
#   2015/10

#require 'active_support/concern' #Rails 3

module Smile
  module Controllers
    module ProjectsOverride
      module CopyProjectPermission
        # extend ActiveSupport::Concern

        def self.prepended(base)
          copy_project_permission_methods = [
            :can_copy_project, # 1/ new method
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}    instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length + 15)}  --->  "
          last_postfix       = '< (SM::CO::ProjectsOverride::CopyProjectPermission)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          ################
          # Smile specific #367502 Création d'un projet à partir d'un template
          base.instance_eval do
            # Remove existing callback
            skip_before_action :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]

            # Recreate callback : remove copy action -> not only for admin
            before_action :require_admin, :only => [ :archive, :unarchive, :destroy ]

            # Copy action only if copy project permission
            before_action :can_copy_project, :only => [ :copy ]
          end

          base._process_action_callbacks.each do |f|
            next if f.filter != :require_admin
            # next if f.options[:only] != [ :archive, :unarchive, :destroy ]

            SmileTools.trace_override "#{base.name}       before_action  #{f.filter} raw=#{f.raw_filter}  -- (SM::CO::IssuesOverride::CopyProjectPermission)",
              true,
              :redmine_admin_enhancements
          end

          base._process_action_callbacks.each do |f|
            next if f.filter != :can_copy_project

            SmileTools.trace_override "#{base.name}       before_action  #{f.filter} raw=#{f.raw_filter}  -- (SM::CO::IssuesOverride::CopyProjectPermission)",
              true,
              :redmine_admin_enhancements
          end
          # END -- Smile specific #367502 Création d'un projet à partir d'un template
          #######################
        end # def self.prepended(base)

        # 1/ New method, RM 2.6.1 OK
        # Smile specific #367502 Création d'un projet à partir d'un template
        def can_copy_project
          @source_project = Project.find(params[:id])

          unless @source_project && User.current.allowed_to?(:copy_project, @source_project)
            deny_access
          else
            true
          end
        end
      end # module CopyProjectPermission


      module ActionsKeepFilters
        def self.prepended(base)
          enhancements_instance_methods = [
            :archive,   # 1/ REWRITTEN, RM V4.0.0 OK
            :unarchive, # 2/ REWRITTEN, RM V4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}    instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length + 15)}  --->  "
          last_postfix       = '< (SM::CO::ProjectsOverride::ActionsKeepFilters)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )
        end

        # 1/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
        def archive
          unless @project.archive
            flash[:error] = l(:error_can_not_archive_project)
          end

          # Smile specific #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
          # Smile specific : params name, parent
          redirect_to_referer_or admin_projects_path(:status => params[:status], :name => params[:name], :parent => params[:parent])
        end

        # 2/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
        def unarchive
          unless @project.active?
            @project.unarchive
          end

          ################
          # Smile specific #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
          # Smile specific : + params name, parent
          redirect_to_referer_or admin_projects_path(:status => params[:status], :name => params[:name], :parent => params[:parent])
        end

        # 2/ REWRITTEN, RM 4.0.0 OK
        # Smile specific #416800 Admin projets : archiver / désarchiver ne reste pas sur les filtres courants
        #
        # Delete @project
        def destroy
          @project_to_destroy = @project
          if api_request? || params[:confirm]
            @project_to_destroy.destroy
            respond_to do |format|
              ################
              # Smile specific : keep status, name, parent params
              format.html { redirect_to admin_projects_path(:status => params[:status], :name => params[:name], :parent => params[:parent]) }
              format.api  { render_api_ok }
            end
          end
          # hide project in layout
          @project = nil
        end
      end # module ActionsKeepFilters
    end # module ProjectsOverride
  end # module Controllers
end # module Smile
