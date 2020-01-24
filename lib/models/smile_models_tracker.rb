# Smile - add methods to the Tracker model
#
# 1/ module MandatoryTracker
#    ClassMethods
#    * #114684 Add a new mandatory flag to the trackers


#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module TrackerOverride
      #####################
      # 1/ MandatoryTracker
      module MandatoryTracker
        # extend ActiveSupport::Concern

        def self.prepended(base)
          last_postfix = '< (SM::MO::TrackerOverride::MandatoryTracker)'

          SmileTools.trace_override "#{base.name}                             sa  mandatory " + last_postfix,
            true,
            :redmine_admin_enhancements

          base.instance_eval do
            safe_attributes 'mandatory'
          end
        end
      end # module MandatoryTracker
    end # module TrackerOverride
  end # module Models
end # module Smile
