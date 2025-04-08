#===============================================================================
# Poisons the target.
#===============================================================================
class Battle::Move::PoisonTarget < Battle::Move
    def canMagicCoat?; return true; end
  
    def initialize(battle, move)
      super
      @toxic = false
    end
  
    def pbFailsAgainstTarget?(user, target, show_message)
      return false if damagingMove?
      return !target.pbCanPoison?(user, show_message, self)
    end
  
    def pbEffectAgainstTarget(user, target)
      return if damagingMove?
      if user.hasActiveAbility?(:NUMBINGPOISON)
        target.pbParalyze(user)
      else
        target.pbPoison(user, nil, @toxic)
      end
    end
  
    def pbAdditionalEffect(user, target)
      return if target.damageState.substitute
      return if !target.pbCanPoison?(user, false, self)
      if user.hasActiveAbility?(:NUMBINGPOISON)
        target.pbParalyze(user)
      else
        target.pbPoison(user, nil, @toxic)
      end
    end
  end
  
  #===============================================================================
  # Poisons the target and decreases its Speed by 1 stage. (Toxic Thread)
  #===============================================================================
  class Battle::Move::PoisonTargetLowerTargetSpeed1 < Battle::Move
    attr_reader :statDown
  
    def initialize(battle, move)
      super
      @statDown = [:SPEED, 1]
    end
  
    def canMagicCoat?; return true; end
  
    def pbFailsAgainstTarget?(user, target, show_message)
      if !target.pbCanPoison?(user, false, self) &&
         !target.pbCanLowerStatStage?(@statDown[0], user, self)
        @battle.pbDisplay(_INTL("But it failed!")) if show_message
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user, target)
      if target.pbCanPoison?(user, false, self)
        if user.hasActiveAbility?(:NUMBINGPOISON)
          target.pbParalyze(user)
        else
          target.pbPoison(user)
        end
      end
      if target.pbCanLowerStatStage?(@statDown[0], user, self)
        target.pbLowerStatStage(@statDown[0], @statDown[1], user)
      end
    end
  end