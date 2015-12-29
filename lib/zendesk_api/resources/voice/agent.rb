module ZendeskAPI
  module Voice
    class Agent < ReadResource
      namespace "channels/voice"

      class Ticket < CreateResource
        def new_record?
          true
        end

        def self.display!(client, options)
          new(client, options).tap do |resource|
            resource.save!(path: resource.path + '/display')
          end
        end
      end

      has_many :tickets, class: 'Ticket'
    end
  end
end
