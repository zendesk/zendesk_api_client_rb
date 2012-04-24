# From https://github.com/rubyworks/facets/blob/master/lib/core/facets/string/modulize.rb
class String
  def modulize
    #gsub('__','/').  # why was this ever here?
    gsub(/__(.?)/){ "::#{$1.upcase}" }.
    gsub(/\/(.?)/){ "::#{$1.upcase}" }.
    gsub(/(?:_+|-+)([a-z])/){ $1.upcase }.
    gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
  end
end
