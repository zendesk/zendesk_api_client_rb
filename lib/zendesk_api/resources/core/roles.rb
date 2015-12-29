module ZendeskAPI
  class CustomRole < DataResource; end

  class Role < DataResource
    # TODO?
    def to_param
      name
    end
  end
end
