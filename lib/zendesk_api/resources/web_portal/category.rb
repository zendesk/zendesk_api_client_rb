module ZendeskAPI
  class Category < Resource
    has_many :forums, class: 'Forum'
  end
end
