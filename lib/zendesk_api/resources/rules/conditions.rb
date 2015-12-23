module ZendeskAPI
  module Conditions
    def all_conditions=(all_conditions)
      self.conditions ||= {}
      self.conditions[:all] = all_conditions
    end

    def any_conditions=(any_conditions)
      self.conditions ||= {}
      self.conditions[:any] = any_conditions
    end

    def add_all_condition(field, operator, value)
      self.conditions ||= {}
      self.conditions[:all] ||= []
      self.conditions[:all] << { :field => field, :operator => operator, :value => value }
    end

    def add_any_condition(field, operator, value)
      self.conditions ||= {}
      self.conditions[:any] ||= []
      self.conditions[:any] << { :field => field, :operator => operator, :value => value }
    end
  end
end
