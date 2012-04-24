# When included into a controller, this module forces the developer
# to explicitly whitelist which parameters are passed to any (or specificed) methods.
#
# Examples:
#
# class TestController < ApplicationController
#   include Zendesk::ParameterWhitelist
#   allow_parameters :forum_id # Only allows params = { :forum_id => VALUE }
#   allow_parameters :topic => :name # Only allows the structure params = { :topic => { :name => VALUE } }
#   allow_parameters :topic => { :forum => :id } # params => { :topic => { :forum => { :id => VALUE } }
#   allow_parameters :topic => %w{title body} # params => { :topic => { :title => VALUE, :body => VALUE } }
#   # The above can also be written as :topic => [:title, :body], but Rails uses indifferent access
#   allow_parameters :forum_id, :only => [:create]
#   allow_parameters :forum_id, :only => :update
# end


require 'hashie'

module Zendesk
  module ParameterWhitelist
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def allow_parameters(*args)
        if args.last.is_a?(Hash) && args.last.has_key?(:only)
          methods = [args.last.delete(:only)].flatten.compact.map(&:to_sym)
        else
          methods = [:all]
        end

        methods.each do |method|
          allowed_parameters[method] += args
        end
      end

      def allowed_parameters
        @allowed_parameters ||= Hash.new {[]}
        @allowed_parameters
      end

      def whitelist_attributes(attributes, action)
        allowed = allowed_parameters[:all] +
          allowed_parameters[action.to_sym]

        mashttribute = Hashie::Mash.new(attributes)
        mallowed = allowed.map {|v| Hash === v ? Hashie::Mash.new(v) : v}
        Sanitizer.populate_parameters(mashttribute, mallowed)
      end
    end

    class Sanitizer
      def self.populate_parameters(hash, allowed)
        h = Hashie::Mash.new 

        allowed.each do |value|
          if value.is_a?(Hash)
            value.each do |k, v|
              next if hash[k].nil?
              h[k] ||= Hashie::Mash.new
              h[k].replace(h[k].deep_merge(populate_parameters(hash[k], [v].flatten)))
            end
          else
            h[value] = hash[value] if hash.has_key?(value)
          end
        end

        h
      end
    end
  end
end
