module ZendeskAPI
  # @private
  module Helpers
    # From https://github.com/rubyworks/facets/blob/master/lib/core/facets/string/modulize.rb
    # Converts a string to module name representation.
    #
    # This is essentially #camelcase, but it also converts
    # '/' to '::' which is useful for converting paths to
    # namespaces.
    #
    # Examples
    #
    #   "method_name".modulize    #=> "MethodName"
    #   "method/name".modulize    #=> "Method::Name"
    #
    # @param string [string] input, `module/class_name`
    # @return [string] a string that can become a class, `Module::ClassName`
    def self.modulize_string(string)
      # gsub('__','/').  # why was this ever here?
      string.gsub(/__(.?)/) { "::#{$1.upcase}" }.
        gsub(/\/(.?)/) { "::#{$1.upcase}" }.
        gsub(/(?:_+|-+)([a-z])/) { $1.upcase }.
        gsub(/(\A|\s)([a-z])/) { $1 + $2.upcase }
    end

    # From https://github.com/rubyworks/facets/blob/master/lib/core/facets/string/snakecase.rb
    # Underscore a string such that camelcase, dashes and spaces are
    # replaced by underscores. This is the reverse of {#camelcase},
    # albeit not an exact inverse.
    #
    #   "SnakeCase".snakecase         #=> "snake_case"
    #   "Snake-Case".snakecase        #=> "snake_case"
    #   "Snake Case".snakecase        #=> "snake_case"
    #   "Snake  -  Case".snakecase    #=> "snake_case"
    def self.snakecase_string(string)
      # gsub(/::/, '/').
      string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        gsub(/\s/, '_').
        gsub(/__+/, '_').
        downcase
    end
  end
end
