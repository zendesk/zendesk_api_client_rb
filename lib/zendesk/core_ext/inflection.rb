require 'inflection'

class String
  def singular
    Inflection.singular(self)
  end
  
  def plural
    Inflection.plural(self)
  end
end
