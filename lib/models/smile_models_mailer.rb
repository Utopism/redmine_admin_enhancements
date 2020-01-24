# Smile - add methods to the Mailer model
#
# 1/ module RedirectMailsToAuthor
# * #782168 V4.0.0 : Plugin option to redirect all notifications to the action author


#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module MailerOverride
      #*************************
      # 1/ RedirectMailsToAuthor
      module RedirectMailsToAuthor
        # extend ActiveSupport::Concern

        def self.prepended(base)
          trace_prefix       = "#{' ' * (base.name.length + 30)}  --->  "
          last_postfix       = '< (SM::MO::MailerOverride::RedirectMailsToAuthor)'

          #####################
          # 1/ Instance methods
          redirect_mails_instance_methods = [
            :mail,                      # 1/  REWRITTEN   RM 4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          smile_instance_methods += base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = redirect_mails_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS           instance_methods  "
          else
            trace_first_prefix = "#{base.name}                instance_methods  "
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

          ##################
          # 2/ Class methods
          redirect_mails_class_methods = [
            :email_addresses,           # 1/  REWRITTEN   RM 4.0.0 OK
          ]

          last_postfix       = '< (SM::MO::MailerOverride::RedirectMailsToAuthor::CMeths)'

          base.singleton_class.prepend ClassMethods

          smile_class_methods = base.methods.select{|m|
              base.method(m).owner == ClassMethods
            }

          missing_class_methods = redirect_mails_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "#{base.name} MISS                    methods  "
          else
            trace_first_prefix = "#{base.name}                         methods  "
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
        end # def self.prepended(base)

        # 1) REWRITTEN, RM V4.0.0 OK
        # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
        def mail(headers={}, &block)
          headers.reverse_merge! 'X-Mailer' => 'Redmine',
                  'X-Redmine-Host' => Setting.host_name,
                  'X-Redmine-Site' => Setting.app_title,
                  'X-Auto-Response-Suppress' => 'All',
                  'Auto-Submitted' => 'auto-generated',
                  'From' => Setting.mail_from,
                  'List-Id' => "<#{Setting.mail_from.to_s.tr('@', '.')}>"

          ################
          # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
          redirect_notifications_to_author = (
              Setting.plugin_redmine_smile_enhancements['redirect_notifications_to_author'] &&
              @author.present? &&
              @author.mail.present?
            )
          if redirect_notifications_to_author
            Rails.logger.debug " =>mail   redirect mails to author #{@author.mail}"
          end
          # END -- Smile specific
          #######################

          # Replaces users with their email addresses
          [:to, :cc, :bcc].each do |key|
            if headers[key].present?
              ################
              # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
              # Smile specific : param redirect_to_author added
              # => emails with user name
              headers[key] = self.class.email_addresses(headers[key], redirect_notifications_to_author)
            end
          end

          # Removes the author from the recipients and cc
          # if the author does not want to receive notifications
          # about what the author do
          if @author && @author.logged? && @author.pref.no_self_notified
            addresses = @author.mails
            headers[:to] -= addresses if headers[:to].is_a?(Array)
            headers[:cc] -= addresses if headers[:cc].is_a?(Array)
          end

          if @author && @author.logged?
            redmine_headers 'Sender' => @author.login
          end

          # Blind carbon copy recipients
          if Setting.bcc_recipients?
            headers[:bcc] = [headers[:to], headers[:cc]].flatten.uniq.reject(&:blank?)
            headers[:to] = nil
            headers[:cc] = nil
          end

          ################
          # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
          if redirect_notifications_to_author
            @messages_mail_transfered_to_autor = []

            [:to, :cc, :bcc].each do |key|
              if headers[key].present?
                headers[key].each do |h|
                  @messages_mail_transfered_to_autor << [key, h]
                end
              end

              headers[key] = nil
            end

            headers[:to] = [@author.mail]
            Rails.logger.debug " =>mail   headers[:to] := #{headers[:to].inspect}"
          end
          # END -- Smile specific
          #######################

          if @message_id_object
            headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
          end
          if @references_objects
            headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
          end

          the_super_method = method(__method__).super_method.super_method
          #Rails.logger.debug  " =>mail   method            =#{method(__method__).inspect}"
          #Rails.logger.debug  " =>mail   super method      =#{method(__method__).super_method.inspect}"
          #Rails.logger.debug  " =>mail   super super method=#{the_super_method}"

          if block_given?
            # Smile specific call super super method : the original super
            
            the_super_method.call headers, &block
            # Smile comment : UPSTREAM code
            # super headers, &block
          else
            # Smile specific call super super method : the original super
            the_super_method.call headers do |format|
              format.text
              format.html unless Setting.plain_text_mail?
            end
            # Smile comment : UPSTREAM code
            # super headers do |format|
            # ...
          end
        end

        module ClassMethods
          # 1) REWRITTEN, RM V4.0.0 OK
          # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
          # Smile specific : param added :
          # * redirect_to_author
          #
          # Returns an array of email addresses to notify by
          # replacing users in arg with their notified email addresses
          #
          # Example:
          #   Mailer.email_addresses(users)
          #   => ["foo@example.net", "bar@example.net"]
          def email_addresses(arg, redirect_to_author=false)
            arr = Array.wrap(arg)
            mails = arr.reject {|a| a.is_a? Principal}
            users = arr - mails
            if users.any?
              ################
              # Smile specific #782168 V4.0.0 : Plugin option to redirect all notifications to the action author
              if redirect_to_author
                users_id_and_address = EmailAddress.
                  where(:user_id => users.map(&:id)).
                  where("is_default = ? OR notify = ?", true, true).
                  pluck(:user_id, :address).
                  uniq


                users_by_id = users.group_by {|u| u.id}

                users_id_and_address.collect! do |user_id, address|
                  user = users_by_id[user_id].first
                  "#{user ? user.name : '?'} <#{address}>"
                end

                Rails.logger.debug " =>mail   mails (users) #{users_id_and_address.inspect}"

                mails += users_id_and_address
              else
                ###############
                # Smile comment : UPSTREAM code
                mails += EmailAddress.
                  where(:user_id => users.map(&:id)).
                  where("is_default = ? OR notify = ?", true, true).
                  pluck(:address)
              end
              # END -- Smile specific
              #######################
            end
            mails
          end
        end # module ClassMethods
      end # module RedirectMailsToAuthor
    end # module MailerOverride
  end # module Models
end # module Smile
