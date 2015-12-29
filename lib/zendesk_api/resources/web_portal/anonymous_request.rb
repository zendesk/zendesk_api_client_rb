module ZendeskAPI
  class AnonymousRequest < CreateResource
    def self.singular_resource_name
      'request'
    end

    namespace 'portal'
  end
end
