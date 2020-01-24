# Smile - override methods to the Admin controller
#
# 1/ module Enhancements
#    - #156114 Projects admin, show issues count
#      2018

#require 'active_support/concern' #Rails 3

module Smile
  module Controllers
    module AdminOverride
      #################
      # 3/ Enhancements
      module Enhancements
        def self.prepended(base)
          enhancements_instance_methods = [
            :projects,             # 1/ OVERRIDEN rewritten RM 4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}       instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length - 5)}                  --->  "
          last_postfix       = '< (SM::CO::Admin::Enhancements)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )
        end # def self.included(base)

        # 1/ OVERRIDEN rewritten, RM 4.0.0 OK
        # Smile specific #156114 Projects admin, show issues count
        def projects
          @status = params[:status] || 1

          scope = Project.status(@status).sorted
          scope = scope.like(params[:name]) if params[:name].present?

          ##########################################################
          # Smile specific #156114 Projects admin, show issues count
          scope = scope.having_parent(params[:parent]) if params[:parent].present?

          @project_count = scope.count
          ###########################################
          # Smile specific : paginator full namespace
          @project_pages = Redmine::Pagination::Paginator.new @project_count, per_page_option, params['page']
          @projects = scope.limit(@project_pages.per_page).offset(@project_pages.offset).to_a

          render :action => "projects", :layout => false if request.xhr?
        end
      end # module Enhancements
    end # module AdminOverride
  end # module Controllers
end # module Smile
