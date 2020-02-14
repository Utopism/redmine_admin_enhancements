# Smile - projects_helper enhancement
# module Smile::Helpers::ProjectsOverride
#
# - 1/ #229028 Projects list : button to hide / show sub-projects
#   2014-01-20
#   module ::HideChildren


module Smile
  module Helpers
    module ProjectsOverride
      #****************
      # 1/ HideChildren
      module HideChildren
        def self.prepended(base)
          hide_children_instance_methods = [
            :render_project_hierarchy, # 1/ REWRITTEN RM 4.0.0 OK
          ]


          base.module_eval do
            # 1/ REWRITTEN, RM 4.0.0 OK
            # Smile specific #229028 Projects list : button to hide / show sub-projects
            #
            # Renders the projects index
            def render_project_hierarchy(projects)
              ###########################################################################
              # Smile specific #229028 Projects list : button to hide / show sub-projects
              s_with_js = (
                "<script language=\"javascript\">\n" +
                "  function toggleDivGroup(el) {\n" +
                "    var div = $(el).parents('div').first();\n" +
                "    var n = div.next();\n" +
                "    div.toggleClass('closed');\n" +
                "    while (n.length && !n.hasClass('group')) {\n" +
                "      n.toggle();\n" +
                "      n = n.next('div');\n" +
                "     }\n" +
                "  }\n" +
                "</script>\n"
              ).html_safe
              # END -- Smile specific #229028 Projects list : button to hide / show sub-projects
              ##################################################################################

              s_with_js << render_project_nested_lists(projects) do |project|
                ###########################################################################
                # Smile specific #229028 Projects list : button to hide / show sub-projects
                s = ''.html_safe
                s << '<span class="expander" onclick="toggleDivGroup(this);">&nbsp;</span>&nbsp;'.html_safe unless project.leaf?
                # END -- Smile specific #229028 Projects list : button to hide / show sub-projects
                ##################################################################################

                s << link_to_project(project, {}, :class => "#{project.css_classes} #{User.current.member_of?(project) ? 'icon icon-fav my-project' : nil}")
                if project.description.present?
                  s << content_tag('div', textilizable(project.short_description, :project => project), :class => 'wiki description')
                end
                s
              end

              # Smile specific #229028 Projects list : button to hide / show sub-projects
              s_with_js
            end
          end # base.module_eval do


          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::ProjectsOverride::HideChildren)'

          smile_instance_methods = base.instance_methods.select{|m|
              hide_children_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_projects', :redmine_admin_enhancements)
            }

          missing_instance_methods = hide_children_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS   instance_methods  "
          else
            trace_first_prefix = "#{base.name}        instance_methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_instance_methods.any? ?
              missing_instance_methods :
              smile_instance_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended
      end # module HideChildren
    end # module ProjectsOverride
  end # module Helpers
end # module Smile
