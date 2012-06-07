# Shamelessly stolen and modified from https://github.com/archan937/dirty_hashy

module ZendeskAPI
  module TrackChanges
    def self.included(base)
      base.method_defined?(:regular_writer).tap do |defined|
        base.send :include, InstanceMethods
        unless defined
          base.send :alias_method, :_store, :store
          base.send :alias_method, :store, :regular_writer
          base.send :alias_method, :[]=, :store
          base.send :define_method, :update do |other|
            other.each{|key, value| store key, value}
          end
          base.send :alias_method, :merge!, :update
        end
      end
    end

    module InstanceMethods
      def clear_changes
        each do |k, v|
          v.clear_changes if v.respond_to?(:clear_changes)
        end

        changes.clear
      end

      def replace(other)
        clear
        merge! other
      end

      def clear
        keys.each{|key| delete key}
      end

      def [](key)
        super(key)
      end

      def regular_writer(key, value)
        changes[key] = value
        defined?(_store) ? _store(key, value) : super(key, value)
      end

      def delete(key)
        self[key] = nil
        super
      end

      def changes
        (@changes ||= self.class.superclass.new).tap do |changes|
          each do |k, v|
            if v.respond_to?(:changed?) && v.changed?
              changes[k] = v.changes
            end
          end
        end
      end

      def changed?(key = nil)
        if key.nil?
          !changes.empty? || any? {|_, v| v.respond_to?(:changed?) && v.changed?}
        else
          changes.key?(key)
        end
      end
      alias :dirty? :changed?
    end
  end
end
