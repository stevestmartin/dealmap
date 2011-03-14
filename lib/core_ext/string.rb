# Custom string extensions
class String
  # {http://www.urbandictionary.com/define.php?term=ganked Ganked} from ActiveSupport::Inflections.  Works the same way it does in rails.
  def underscore
    word = self.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

