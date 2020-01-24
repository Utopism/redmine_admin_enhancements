# encoding: UTF-8

# Smile - add methods to the ProjectCustomField model
#

# module ProjectCustomFieldEditionRole
# * #321160 Role-based project custom field editability
# * #771072 [4.0.0] Project custom fields not editable in settings after custom field visiblity changed

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module ProjectCustomFieldOverride
      #*********************************
      # 1/ ProjectCustomFieldEditionRole
      module ProjectCustomFieldEditionRole
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance Methods
          project_custom_field_edition_role_instance_methods = [
            :editable_by?,                  # 1/ New method
            :bool_custom_value_set_on=,     # 2/ New method
            :reset_available_custom_fields, # 3/ New method
          ]

          trace_prefix = "#{' ' * (base.name.length + 15)} --->  "
          last_postfix = '< (SM::MO::ProjectCustomFieldOverride::ProjectCustomFieldEditionRole)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = project_custom_field_edition_role_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "ProjectCF MISS        instance_methods  "
          else
            trace_first_prefix = "#{base.name}    instance_methods  "
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


          SmileTools.trace_override "#{base.name}                hbtm  projects " + last_postfix
          SmileTools.trace_override "#{base.name}                  sa  project_ids " + last_postfix
          base.instance_eval do
            has_and_belongs_to_many :projects, :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}", :foreign_key => "custom_field_id"

            safe_attributes 'project_ids'
          end


          ##############
          # 2/ Callbacks
          base.instance_eval do
            after_commit :reset_available_custom_fields, on: [:create, :update, :destroy]
          end

          new_callback_names = [
            :reset_available_custom_fields,
          ]

          update_callback_names = base._commit_callbacks.collect{|cb|
              next unless cb.kind == :after
              cb.filter
            }

          missing_callbacks = new_callback_names.select{|cb|
              ! update_callback_names.include?(cb)
            }

          if missing_callbacks.any?
            trace_first_prefix = "#{base.name} MISS      callbacks  "
          else
            trace_first_prefix = "#{base.name}           callbacks  "
          end

          SmileTools::trace_by_line(
            (
              missing_callbacks.any? ?
              missing_callbacks :
              new_callback_names
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_admin_enhancements
          )

          if missing_callbacks.any?
            raise trace_first_prefix + missing_callbacks.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended(base)


        # 1/ New method, RM 2.6 OK
        # Smile specific #321160 Role-based project custom field editability
        def editable_by?(project, user=User.current)
          # TODO jebat manage relay role
          return true if user.admin?

          return true if editable

          logger.debug "\\=>roles editable_by? project cf #{self.id}/#{self.name} P:#{project.identifier} u:#{user.login}"

          #--------------
          # 1/ User roles
          logger.debug " =>roles   cf roles=#{roles.collect(&:name)}"

          roles_for_project_for_user = user.roles_for_project(project)
          logger.debug " =>roles   roles_for_project_for_user=#{roles_for_project_for_user.collect(&:name)}"

          roles_for_project_for_user_for_cf = roles & roles_for_project_for_user

          if roles_for_project_for_user_for_cf.present?
            logger.debug "/=>roles   OK  #{roles_for_project_for_user_for_cf.collect(&:name)}"

            return true
          end

          #---------------
          # 2/ Relay roles
          relay_roles_for_project_for_user = user.relay_roles_for_project(project, true)
          logger.debug " =>roles   relay_roles_for_project_for_user=#{relay_roles_for_project_for_user.collect(&:name)}"

          relay_roles_for_project_for_user_for_cf = roles & relay_roles_for_project_for_user

          if relay_roles_for_project_for_user_for_cf.present?
            logger.debug "/=>roles   OK  #{relay_roles_for_project_for_user_for_cf.collect(&:name)}"

            return true
          end

          logger.debug "/=>roles   KO"

          false
        end

        # 2/ New method, RM 2.6 OK
        # Set Project boolean custom field to on only for projects provided
        # Smile specific #321160 Role-based project custom field editability
        def bool_custom_value_set_on=(project_ids)
          return if field_format != 'bool'

          return if multiple

          # Remove projects disabled
          custom_values.each{|cv|
            next if project_ids.include?(cv.customized_id.to_s)

            cv.destroy
          }

          project_ids.each{|project_id|
            # Return the first cv found for the project
            cv = custom_values.detect{|cv| cv.customized_id == project_id.to_i}

            if cv
              # Enable the boolean value on this project for this custom field
              if cv.value != '1'
                cv.value = '1'
                cv.save
              end
            else
              # Add a new custom value for this custom field
              custom_values << CustomValue.new(
                :customized_type => 'Project',
                :custom_field_id => self.id,
                :customized_id => project_id.to_i,
                :value => '1'
              )
            end
          }
        end

        # 3/ New method, RM 4.0.0 OK
        def reset_available_custom_fields
          Project.reset_available_custom_fields
        end
      end # module ProjectCustomFieldEditionRole
    end # module ProjectOverride
  end # module Models
end # module Smile
