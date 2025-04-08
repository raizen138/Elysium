class Battle  
  def pbEntryHazards(battler)
    if !battler.hasActiveAbility?(:SPINNINGENTRY)
      battler_side = battler.pbOwnSide
      # Stealth Rock
      if battler_side.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
        GameData::Type.exists?(:ROCK) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        bTypes = battler.pbTypes(true)
        eff = Effectiveness.calculate(:ROCK, *bTypes)
        if !Effectiveness.ineffective?(eff)
          battler.pbReduceHP(battler.totalhp * eff / 8, false)
          pbDisplay(_INTL("Pointed stones dug into {1}!", battler.pbThis))
          battler.pbItemHPHealCheck
        end
      end
      # Spikes
      if battler_side.effects[PBEffects::Spikes] > 0 && battler.takesIndirectDamage? &&
        !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        spikesDiv = [8, 6, 4][battler_side.effects[PBEffects::Spikes] - 1]
        battler.pbReduceHP(battler.totalhp / spikesDiv, false)
        pbDisplay(_INTL("{1} is hurt by the spikes!", battler.pbThis))
        battler.pbItemHPHealCheck
      end
      # Toxic Spikes
      if battler_side.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.airborne?
        if battler.pbHasType?(:POISON)
          battler_side.effects[PBEffects::ToxicSpikes] = 0
          pbDisplay(_INTL("{1} absorbed the poison spikes!", battler.pbThis))
        elsif battler.pbCanPoison?(nil, false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
          if battler_side.effects[PBEffects::ToxicSpikes] == 2
            battler.pbPoison(nil, _INTL("{1} was badly poisoned by the poison spikes!", battler.pbThis), true)
          else
            battler.pbPoison(nil, _INTL("{1} was poisoned by the poison spikes!", battler.pbThis))
          end
        end
      end
      # Sticky Web
      if battler_side.effects[PBEffects::StickyWeb] && !battler.fainted? && !battler.airborne? &&
        !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        pbDisplay(_INTL("{1} was caught in a sticky web!", battler.pbThis))
        if battler.pbCanLowerStatStage?(:SPEED)
          battler.pbLowerStatStage(:SPEED, 1, nil)
          battler.pbItemStatRestoreCheck
        end
      end
    end
  end
end

#===============================================================================
# Wing Move
#===============================================================================
class Battle::Move   
  def wingMove?;          return @flags.any? { |f| f[/^Wing$/i] };            end
end

#===============================================================================
# Battler
#===============================================================================
class Battle::Battler
  #===============================================================================
  # Custom ability: WAYOFPRECISION
  #===============================================================================
  def pbFlinch(_user = nil)
    return if (hasActiveAbility?(:INNERFOCUS) || hasActiveAbility?(:WAYOFPRECISION)) && !@battle.moldBreaker
    @effects[PBEffects::Flinch] = true
  end

  alias custom_pbLowerAttackStatStageIntimidate pbLowerAttackStatStageIntimidate
  def pbLowerAttackStatStageIntimidate(user)
    return false if fainted?
    if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:WAYOFPRECISION])
      @battle.pbShowAbilitySplash(self)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", pbThis, GameData::Stat.get(:ATTACK).name))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", pbThis, abilityName,
                                GameData::Stat.get(:ATTACK).name))
      end
      @battle.pbHideAbilitySplash(self)
      return false
    end
    return custom_pbLowerAttackStatStageIntimidate(user)
  end
end