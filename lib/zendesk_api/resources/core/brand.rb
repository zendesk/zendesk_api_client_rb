module ZendeskAPI
  class Brand < Resource
    def destroy!
      self.active = false
      save!

      super
    end
  end
end
