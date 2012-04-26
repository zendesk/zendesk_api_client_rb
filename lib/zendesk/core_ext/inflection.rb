require 'inflection'

Inflection.plural_rule 'forum', 'forums'

class String
  def singular
    Inflection.singular(self)
  end
  
  def plural
    Inflection.plural(self)
  end
end
