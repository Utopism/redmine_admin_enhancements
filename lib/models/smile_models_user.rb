# Smile - add methods to the User model
#
# 1/ module MemberShipsWithArchivedProjects
# * #769702 V4.0.0 : User memberships, params to show archived projects
#   2019-02


#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module UserOverride
      ####################################
      # 3/ MemberShipsWithArchivedProjects
      module MemberShipsWithArchivedProjects
        def self.prepended(base)
          base.class_eval do
            ##################
            # 1) New Relations
            # Smile specific #769702 V4.0.0 : User memberships, params to show archived projects
            has_many :memberships_all,
              lambda {joins(:project)},
              :class_name => 'Member',
              :foreign_key => 'user_id'
          end

          module_relations = [
            :memberships_all,
          ]

          trace_prefix       = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix       = '< (SM::MO::UserOverride::MemberShipsWithArchivedProjects'

          assocs = base.reflect_on_all_associations(:has_many).collect(&:name)
          missing_relations = module_relations.select{|s|
              ! assocs.include?(s)
            }

          if missing_relations.any?
            trace_first_prefix = "#{base.name} MISS                    relations  "
          else
            trace_first_prefix = "#{base.name}                         relations  "
          end

          SmileTools::trace_by_line(
            ( missing_relations.any? ? missing_relations : module_relations ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          if missing_relations.any?
            raise trace_first_prefix + missing_relations.join(', ') + '  ' + last_postfix
          end
        end
      end
    end # module UserOverride
  end # module Models
end # module Smile
