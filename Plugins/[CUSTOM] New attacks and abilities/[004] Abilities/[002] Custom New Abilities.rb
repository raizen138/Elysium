#===============================================================================
# ModifyMoveBaseType handlers
#===============================================================================
Battle::AbilityEffects::ModifyMoveBaseType.add(:INTOXICATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:POISON)
    move.powerBoost = true
    next :POISON
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:POLLINATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:BUG)
    move.powerBoost = true
    next :BUG
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:EMANATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:PSYCHIC)
    move.powerBoost = true
    next :PSYCHIC
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:IMMOLATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FIRE)
    move.powerBoost = true
    next :FIRE
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:HYDRATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:WATER)
    move.powerBoost = true
    next :WATER
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:SPECTRALIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:GHOST)
    move.powerBoost = true
    next :GHOST
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:MINERALIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:ROCK)
    move.powerBoost = true
    next :ROCK
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:DRACONIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:DRAGON)
    move.powerBoost = true
    next :DRAGON
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:FERTILIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:GRASS)
    move.powerBoost = true
    next :GRASS
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:WORKINIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FIGHTING)
    move.powerBoost = true
    next :FIGHTING
  }
)

#===============================================================================
# MoveImmunity handlers
#===============================================================================
Battle::AbilityEffects::MoveImmunity.add(:POISONABSORB,
	proc { |ability, user, target, move, type, battle, show_message|
		next target.pbMoveImmunityHealingAbility(user, move, type, :POISON, show_message)
	}
)

#===============================================================================
# DamageCalcFromUser handlers
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.copy(:AERILATE, :GALVANIZE, :NORMALIZE, :PIXILATE, :REFRIGERATE, :INTOXICATE, :POLLINATE, :EMANATE, :IMMOLATE, :HYDRATE, :SPECTRALIZE, :MINERALIZE, :DRACONIZE, :FERTILIZE, :WORKINIZE)

Battle::AbilityEffects::DamageCalcFromUser.add(:OVERCHARGED,
  proc { |ability, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GIANTWINGS,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.5 if move.wingMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:IRONFIST, :ATOMICPUNCH)
Battle::AbilityEffects::DamageCalcFromUser.copy(:STEELWORKER, :ATOMICPUNCH)


#===============================================================================
# OnEndOfUsingMove handlers
#===============================================================================
Battle::AbilityEffects::OnEndOfUsingMove.add(:OVERCHARGED,
  proc { |ability, user, targets, move, battle|
    next if !user.takesIndirectDamage?
    next if move.type != :ELECTRIC
    next if !move.damagingMove?
    damageDealt = 0
    targets.each { |target| damageDealt += target.damageState.hpLost if !target.damageState.unaffected && !target.damageState.substitute }
    next if damageDealt == 0
    battle.pbShowAbilitySplash(user)
    user.pbTakeEffectDamage((damageDealt / 4).round)
    battle.pbDisplay(_INTL("{1} got hurt by it's own attack!", user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# OnSwitchIn handlers
#===============================================================================
Battle::AbilityEffects::OnSwitchIn.add(:SPINNINGENTRY,
  proc { |ability, battler, battle, switch_in|
    next if Settings::MECHANICS_GENERATION >= 9 && battler.ability_triggered?
    foes = battle.allOtherSideBattlers(battler.index)
    battle.pbAnimation("RAPIDSPIN", battler, foes)
    battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
    if battler.pbOwnSide.effects[PBEffects::StealthRock]
      battler.pbOwnSide.effects[PBEffects::StealthRock] = false
      battle.pbDisplay(_INTL("{1} blew away stealth rocks!", battler.pbThis))
    end
    if battler.pbOwnSide.effects[PBEffects::Spikes] > 0
      battler.pbOwnSide.effects[PBEffects::Spikes] = 0
      battle.pbDisplay(_INTL("{1} blew away spikes!", battler.pbThis))
    end
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      battle.pbDisplay(_INTL("{1} blew away poison spikes!", battler.pbThis))
    end
    if battler.pbOwnSide.effects[PBEffects::StickyWeb]
      battler.pbOwnSide.effects[PBEffects::StickyWeb] = false
      battle.pbDisplay(_INTL("{1} blew away sticky webs!", battler.pbThis))
    end
    battle.pbSetAbilityTrigger(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ATOMICPUNCH,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has two Abilities!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.ability_id = ability
  }
)

Battle::AbilityEffects::OnSwitchIn.copy(:ATOMICPUNCH, :WAYOFPRECISION, :WAYOFSWIFTNESS)

#===============================================================================
# OnDealingHit handlers
#===============================================================================
Battle::AbilityEffects::OnDealingHit.add(:POISONSCALES,
  proc { |ability, user, target, move, battle|
    next if move.contactMove?
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user, Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!", user.pbThis, user.abilityName, target.pbThis(true))
      end
      target.pbPoison(user, msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# SpeedCalc handlers
#===============================================================================
Battle::AbilityEffects::SpeedCalc.copy(:SWIFTSWIM, :WAYOFSWIFTNESS)
