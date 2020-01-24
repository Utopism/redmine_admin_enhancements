# encoding: UTF-8

# Smile - add methods to the Project model
#
# 1/ module ProjectCustomFieldEditionRole
# * #321160 Role-based project custom field editability
#   2015

# 2/ module NewScopes
# * #156114 Projects admin, show issues count
#   2018-11

#require 'active_support/concern' #Rails 3


module Smile
  module Models
    module ProjectOverride
      #*********************************
      # 1/ ProjectCustomFieldEditionRole
      module ProjectCustomFieldEditionRole
        # extend ActiveSupport::Concern

        def self.prepended(base)
          project_custom_field_edition_role_instance_methods = [
            :editable_custom_field_values, # 1/ New method
            :safe_attributes=,             # 2/ OVERRIDEN extended V4.0.0 OK
          ]

          trace_prefix       = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::ProjectOverride::ProjectCustomFieldEditionRole)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = project_custom_field_edition_role_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS          instance_methods  "
          else
            trace_first_prefix = "#{base.name}               instance_methods  "
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
        end # def self.prepended(base)

        # 1/ New method, RM 4.0.0 OK
        # Smile specific #321160 Role-based project custom field editability
        #
        # Returns the custom_field_values that can be edited by the given user
        def editable_custom_field_values(user=nil)
          user_real = user || User.current
          custom_field_values.select do |value|
            value.custom_field.editable_by?(project, user_real)
          end
        end

        # 2/ OVERRIDEN extended, RM 4.0.0 OK
        # Smile specific #321160 Role-based project custom field editability
        # Smile comment : override to filter non editable custom fields
        def safe_attributes=(attrs, user=User.current)
          if attrs.respond_to?(:to_unsafe_hash)
            attrs = attrs.to_unsafe_hash
          end

          return unless attrs.is_a?(Hash)

          if attrs['custom_field_values'].present?
            editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
            attrs['custom_field_values'].select! {|k, v| editable_custom_field_ids.include?(k.to_s)}
          end

          if attrs['custom_fields'].present?
            editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
            attrs['custom_fields'].select! {|c| editable_custom_field_ids.include?(c['id'].to_s)}
          end

          super(attrs, user)
        end
      end # module ProjectCustomFieldEditionRole

      #*************
      # 2/ NewScopes
      module NewScopes
        # extend ActiveSupport::Concern

        def self.prepended(base)
          trace_prefix       = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::ProjectOverride::NewScopes::CMeths)'

          ###########
          # 1) Scopes
          # Smile specific #156114 Projects admin, show issues count
          SmileTools.trace_override "#{base.name}                          scope  having_parent " + last_postfix,
            :redmine_admin_enhancements

          base.instance_eval do
            scope :having_parent, lambda { |parent_name, including_itself=false|
              parent = Project.find_by_name(parent_name)
              if parent
                operator_equal = (including_itself ? '=' : '')
                where("lft >#{operator_equal} ?", parent.lft).where("rgt <#{operator_equal} ?", parent.rgt)
              else
                none
              end
            }
          end
        end # def self.prepended
      end # module NewScopes
    end # module ProjectOverride
  end # module Models
end # module Smile
