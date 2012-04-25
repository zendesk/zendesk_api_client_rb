require 'hashie'

module Zendesk
  # See {ClassMethods}
  module ParameterWhitelist
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      # Sets class-wide allowed parameters. Can be sent an :only option so that these
      # parameters can be allowed only on certain actions.
      #
      # Examples:
      #
      # allow_parameters :forum_id # Only allows { :forum_id => VALUE }
      #
      # allow_parameters :topic => :name # Only allows the structure { :topic => { :name => VALUE } }
      #
      # allow_parameters :topic => { :forum => :id } # { :topic => { :forum => { :id => VALUE } }
      #
      # allow_parameters :topic => [:title, :body] # { :topic => { :title => VALUE, :body => VALUE } }
      #
      # allow_parameters :forum_id, :only => [:create]
      #
      # allow_parameters :forum_id, :only => :update
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

      # Returns allowed parameters. The keys for the hash are either a verb (:put, :post) or :all for those
      # that apply to every action.
      # @return [Hash] Allowed parameters
      def allowed_parameters
        @allowed_parameters ||= Hash.new {[]}
        @allowed_parameters
      end

      # Collects allowed_parameters according to specified action and whitelists passed in
      # attributes.
      #
      # @param [Hash] attributes Attributes to whitelist
      # @param [String/Symbol] action The action being taken (:put/:post generally)
      # @return [Hash] Whitelisted attributes
      def whitelist_attributes(attributes, action)
        allowed = allowed_parameters[:all] +
          allowed_parameters[action.to_sym]

        mashttribute = Hashie::Mash.new(attributes)
        mallowed = allowed.map {|v| Hash === v ? Hashie::Mash.new(v) : v}
        Sanitizer.populate_parameters(mashttribute, mallowed)
      end
    end

    class Sanitizer
      # Recursively populates a new hash with the values from the old hash according to the
      # keys allowed.
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
