require 'core/spec_helper'

describe ZendeskAPI::DynamicContent::Variant, :delete_after do
  def valid_attributes
    {
      :locale_id => 43,
      :active => true,
      :default => false,
      :content => 'Mon dieu!'
    }
  end

  under dynamic_content_item do
    it_should_be_readable dynamic_content_item, :variants, :create => true
    it_should_be_creatable
    it_should_be_updatable :content
    it_should_be_deletable
  end
end
