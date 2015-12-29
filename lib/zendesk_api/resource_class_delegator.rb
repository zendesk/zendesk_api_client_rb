require 'delegate'

module ZendeskAPI
  class ResourceClassDelegator < Delegator
    def __getobj__
      # TODO if @class_str.is_a?(Class)
      # TODO error handling?
      ZendeskAPI.const_get(@class_str)
    end

    def __setobj__(str)
      @class_str = str
    end
  end
end
