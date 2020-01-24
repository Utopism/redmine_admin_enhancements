# Smile - add methods to the Role model
#
# 1/ module ExcludeUnsettable.InstanceMethods
# - #67860 Désactivation des rôles obsolètes lors de l'ajout d'un membre dans un projet
#
# - #322539 Utilisation d'un nouveau champ *settable*
#   2015


#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module RoleOverride
      ######################
      # 1/ ExcludeUnsettable
      module ExcludeUnsettable
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #--------------------
          # 1/ Instance methods
          exclude_unsettable_instance_methods = [
            :unsettable_exception_group, # 1/ new method
            :visible?,                   # 2/ new method
          ]

          trace_prefix = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix = '< (SM::MO::RoleOverride::ExcludeUnsettable)'

          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = exclude_unsettable_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS             instance_methods  "
          else
            trace_first_prefix = "#{base.name}                  instance_methods  "
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


          #-----------------
          # 2/ Class methods
          exclude_unsettable_class_methods = [
            :exclude_unsettable, # 1/ new method
            :only_unsettable,    # 2/ new method
          ]

          base.singleton_class.prepend ClassMethods

          trace_prefix       = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::RoleOverride::ExcludeUnsettable::CMeths)'

          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = exclude_unsettable_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS                      methods  "
          else
            trace_first_prefix = "#{base.name}                           methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_class_methods.any? ?
              missing_class_methods :
              smile_class_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          if missing_class_methods.any?
            raise trace_first_prefix + missing_class_methods.join(', ') + '  ' + last_postfix
          end


          #-------------------
          # 3/ Safe attributes
          new_safe_attributes = [
            'settable',
            'unsettable_exception_groupname',
          ]

          base.instance_eval do
            safe_attributes 'settable'
            safe_attributes 'unsettable_exception_groupname'
          end

          safe_attributes_names = base.safe_attributes.collect(&:first).select{|sa| sa.size == 1}.collect(&:first)

          missing_safe_attributes = new_safe_attributes.select{|sa|
              ! safe_attributes_names.include?(sa)
            }

          if missing_safe_attributes.any?
            trace_first_prefix = "#{base.name} MISS              safe_attributes  "
          else
            trace_first_prefix = "#{base.name}                   safe_attributes  "
          end

          SmileTools::trace_by_line(
            (
              missing_safe_attributes.any? ?
              missing_safe_attributes :
              new_safe_attributes
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          if missing_safe_attributes.any?
            raise trace_first_prefix + missing_safe_attributes.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended

        def unsettable_exception_group(debug=false)
          unless respond_to?(:unsettable_exception_groupname)
            Rails.logger.error "==>roles #{name}   unsettable_exception_group   unsettable_exception_groupname MISSING on role, migration missing ?" if debug

            return nil
          end

          unsettable_exception_groupname = self.unsettable_exception_groupname

          if unsettable_exception_groupname.blank?
            Rails.logger.info "==>roles #{name}   unsettable_exception_group   unsettable_exception_groupname empty" if debug

            return nil
          end

          Rails.logger.info "==>roles #{name} unsettable_exception_group   unsettable_exception_groupname=#{unsettable_exception_groupname}" if debug

          return @unsettable_exception_group if defined?(@unsettable_exception_group)

          @unsettable_exception_group = Group.find_by_lastname(unsettable_exception_groupname)

          if @unsettable_exception_group.nil?
            Rails.logger.error " =>roles #{name}   group NOT found" if debug
          else
            Rails.logger.info " =>roles #{name}   group ##{@unsettable_exception_group.id} found" if debug
          end

          @unsettable_exception_group
        end

        def visible?(user=User.current, debug=false)
          if settable?
            return true
          end

          Rails.logger.debug "==>roles #{name} visible? NOT settable" if debug

          if User.current.admin?
            Rails.logger.debug " =>roles #{name}   true : Admin" if debug

            return true
          end

          exception_group_for_role = unsettable_exception_group(debug)

          if exception_group_for_role.nil?
            Rails.logger.debug " =>roles #{name}   false : unsettable_exception_group NOT found" if debug

            return false
          end

          user_group_names = user.groups.pluck(:lastname)

          Rails.logger.debug " =>roles #{name}   user groups=#{user_group_names.join(', ')}" if debug

          if user_group_names.include?(exception_group_for_role.name)
            Rails.logger.debug " =>excluderoles #{name}   VISIBLE by group exception" if debug

            return true
          end

          Rails.logger.debug " =>roles #{name}   NOT visible for user" if debug

          return false
        end


        module ClassMethods
          # 1/ new method, RM 4.0.2 OK
          # Smile specific #67860 Désactivation des rôles obsolètes lors de l'ajout d'un membre dans un projet
          def exclude_unsettable(p_roles, debug=false)
            if User.current.admin?
              Rails.logger.debug "==>roles exclude_unsettable NOOP : admin" if debug

              return p_roles
            end

            p_roles.select { |r|
              r.visible?(User.current, debug)
            }
          end

          # 2/ new method, RM 4.0.0 OK
          # Smile specific #67860 Désactivation des rôles obsolètes lors de l'ajout d'un membre dans un projet
          def only_unsettable(p_roles)
            p_roles.select { |r|
              ! r.settable?
            }
          end
        end # module ClassMethods
      end # module ExcludeUnsettable
    end # module RoleOverride
  end # module Models
end # module Smile
