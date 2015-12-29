module ZendeskAPI
  class OauthClient < Resource
    namespace "oauth"

    def self.singular_resource_name
      "client"
    end
  end

  class OauthToken < ReadResource
    include Destroy
    namespace "oauth"

    def self.singular_resource_name
      "token"
    end
  end
end
