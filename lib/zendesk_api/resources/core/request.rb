module ZendeskAPI
  class Request < Resource
    class Comment < DataResource
      include Save

      has_many :uploads, class: 'Attachment', inline: true, path: '' # TODO
      has :author, class: 'User'

      # TODO?
      def save
        if new_record?
          save_associations
          true
        else
          false
        end
      end

      alias :save! :save
    end

    has :comment, class: 'Request::Comment', inline: true
    has_many :comments, class: 'Request::Comment'

    has :organization, class: 'Organization'
    has :group, class: 'Group'
    has :requester, class: 'User'
  end
end
