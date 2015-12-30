module ZendeskAPI
  class Locale < ReadResource
    self.resource_name = 'locales'
    self.singular_resource_name = 'locale'

    self.collection_paths = [
      'locales',
      'locales/public',
      'locales/agent'
    ]

    self.resource_paths = ['locales/%{id}'] # TODO support detect_best_locale, current_locale
  end
end
