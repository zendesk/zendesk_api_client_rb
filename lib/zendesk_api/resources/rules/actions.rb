module ZendeskAPI
  module Actions
    def add_action(field, value)
      self.actions ||= []
      self.actions << { :field => field, :value => value }
    end
  end
end
