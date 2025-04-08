#===============================================================================
# Plugin compatibility methods.
#===============================================================================
# Placeholder methods to allow for compatibility with multiple plugins.
#-------------------------------------------------------------------------------
class Pokemon
    def void?;            return false; end
    def holy?;            return false; end
    def demon?;           return false; end
    def astral?;          return false; end
  end
  
  class Battle::Battler
    def void?;            return false; end
    def holy?;            return false; end
    def demon?;           return false; end
    def astral?;          return false; end
    
    def hasVoid?;         return false; end
    def hasHoly?;         return false; end
    def hasDemon?;        return false; end
    def hasAstral?;       return false; end
  end
  
  class Battle::FakeBattler
    def void?;            return false; end
    def holy?;            return false; end
    def demon?;           return false; end
    def astral?;          return false; end
  end