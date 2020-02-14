# Smile - queries_helper enhancement
# * #67860 Désactivation des rôles obsolètes lors de l'ajout d'un membre dans un projet

# module Smile::Helpers::QueriesOverride
# * 1/ module ::RolesSettable

module Smile
  module Helpers
    module QueriesOverride
      #*****************
      # 1/ RolesSettable
      module RolesSettable
        def self.prepended(base)
          roles_settable_instance_methods = [
            # module_eval
            :roles_settable_hook,  #  1/  New method        RM 4.0.0 OK  SMILE
          ]


          # Methods dynamically added to QueriesHelper, source replaced by module_eval
          # Because we can't use normal methods override
          # => no access to super
          # 2012-01-18 no way to include a module in a module (like InstanceMethods)
          # QueryController
          #  -> has a dynamic module (accessible QueryController.with master_helper_module)
          #     -> includes all Controller helpers :
          #        including QueriesHelper
          #          -> includes modules included in the helpers
          #          -> Pb. 1 : includes the sub modules in the dynamic module => duplication !
          #             - methods already present in QueriesHelper -- OK
          #             - Pb. 2 : new methods in the modules included -- NON-OK
          base.module_eval do # <<READER, __FILE__, (__LINE__ + 1) #does not work
            # 1/ New method, RM 4.0.0 OK  SMILE
            # Smile specific #67860 Désactivation des rôles obsolètes lors de l'ajout d'un membre dans un projet
            def roles_settable_hook(roles, debug=nil)
              [
                Role.exclude_unsettable(roles, debug.present?), # settable
                Role.only_unsettable(roles)                     # unsettable
              ]
            end
          end # base.module_eval do

          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::QueriesOverride::RolesSettable)'


          smile_instance_methods = (base.instance_methods + base.protected_instance_methods).select{|m|
              roles_settable_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_queries', :redmine_admin_enhancements)
            }

          missing_instance_methods = roles_settable_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS    instance_methods  "
          else
            trace_first_prefix = "#{base.name}         instance_methods  "
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
      end # module RolesSettable
    end # module QueriesOverride
  end # module Helpers
end # module Smile
