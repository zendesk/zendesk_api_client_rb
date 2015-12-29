module ZendeskAPI
  class App < Resource
    self.resource_name = 'apps'
    self.singular_resource_name = 'app'

    self.collection_paths = [
      'apps',
      'apps/owned'
    ]

    self.resource_paths = ['apps/%{id}']

    def initialize(client, attributes = {})
      attributes[:upload_id] ||= nil

      super
    end

    def self.create!(client, attributes = {}, &block)
      if file_path = attributes.delete(:upload)
        attributes[:upload_id] = client.apps.uploads.create!(:file => file_path).id
      end

      super
    end

    # class Plan < Resource
    # end

    class Upload < Data
      self.resource_name = 'uploads'
      self.singular_resource_name = 'upload'
      self.collection_paths = ['uploads']

      include Create

      def initialize(client, attributes)
        attributes[:file] ||= attributes.delete(:id)

        super
      end

      # Always save
      def changed?
        true
      end

      # Don't nest attributes
      def attributes_for_save
        attributes
      end

      # Not nested under :upload, just returns :id
      def handle_response(response)
        attributes.id = response.body['id'] if response.body
      end
    end

    def self.uploads(client, *args, &block)
      ZendeskAPI::Collection.new(client, Upload, *args, &block)
    end

    def self.installations(client, *args, &block)
      ZendeskAPI::Collection.new(client, AppInstallation, *args, &block)
    end

    has :upload, class: 'App::Upload', inline: true
    has_many :uploads, class: 'App::Upload', path: 'uploads'
    # has_many :plans, class: 'App::Plan'

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      attributes.replace(response.body) if response.body
    end
  end
end
