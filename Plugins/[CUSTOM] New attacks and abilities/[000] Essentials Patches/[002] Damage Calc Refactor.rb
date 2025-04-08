#===============================================================================
# Damage calculation refactoring.
#===============================================================================
#===============================================================================
# AI damage calculation refactoring.
#===============================================================================
class Battle::AI::AIMove
  #-----------------------------------------------------------------------------
  # Calculates damage multipliers from abilities.
  #-----------------------------------------------------------------------------
  def calc_ability_mults(user, target, base_dmg, calc_type, is_critical, multipliers)
    if user.ability_active?
      case user.ability_id
      when :AERILATE, :GALVANIZE, :PIXILATE, :REFRIGERATE, :INTOXICATE, :POLLINATE, :EMANATE, :IMMOLATE, :HYDRATE, :SPECTRALIZE, :MINERALIZE, :DRACONIZE, :FERTILIZE, :WORKINIZE
        multipliers[:power_multiplier] *= 1.2 if type == :NORMAL
      when :ANALYTIC
        if rough_priority(user) <= 0
          user_faster = false
          @ai.each_battler do |b, i|
            user_faster = (i != user.index && user.faster_than?(b))
            break if user_faster
          end
          multipliers[:power_multiplier] *= 1.3 if !user_faster
        end
      when :NEUROFORCE
        if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 1.25
        end
      when :NORMALIZE
        multipliers[:power_multiplier] *= 1.2 if Settings::MECHANICS_GENERATION >= 7
      when :SNIPER
        multipliers[:final_damage_multiplier] *= 1.5 if is_critical
      when :STAKEOUT
        # NOTE: Can't predict whether the target will switch out this round.
      when :TINTEDLENS
        if Effectiveness.resistant_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 2
        end
      else
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user.battler, target.battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
    if !@ai.battle.moldBreaker
      user.battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user.battler, target.battler, @move, multipliers, base_dmg, calc_type
        )
      end
      if target.ability_active?
        case target.ability_id
        when :FILTER, :SOLIDROCK
          if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
            multipliers[:final_damage_multiplier] *= 0.75
          end
        else
          Battle::AbilityEffects.triggerDamageCalcFromTarget(
            target.ability, user.battler, target.battler, @move, multipliers, base_dmg, calc_type
          )
        end
      end
    end
    if target.ability_active?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user.battler, target.battler, @move, multipliers, base_dmg, calc_type
      )
    end
    if !@ai.battle.moldBreaker
      target.battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user.battler, target.battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
  end
end