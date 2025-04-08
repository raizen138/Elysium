class Battle::AI
  CUSTOM_BASE_ABILITY_RATINGS = {
    8  => [:INTOXICATE, :POLLINATE, :EMANATE, :IMMOLATE, :HYDRATE, :SPECTRALIZE, :MINERALIZE, :DRACONIZE, :FERTILIZE, :WORKINIZE],
    7  => [:POISONABSORB, :SPINNINGENTRY],
    6  => [:ATOMICPUNCH, :GIANTWINGS, :OVERCHARGED, :WAYOFSWIFTNESS],
    5  => [:POISONSCALES, :NUMBINGPOISON],
    2  => [:WAYOFPRECISION]
  }

  #===============================================================================
  # AI_Utilities
  #===============================================================================
  # Aliased so AI trainers can recognize immunities from custom abilities.
  #-------------------------------------------------------------------------------
  alias custom_pokemon_can_absorb_move? pokemon_can_absorb_move?
  def pokemon_can_absorb_move?(pkmn, move, move_type)
    return false if pkmn.is_a?(Battle::AI::AIBattler) && !pkmn.ability_active?
    # Check pkmn's ability
    # Anything with a Battle::AbilityEffects::MoveImmunity handler
    case pkmn.ability_id
    when :POISONABSORB
      return move_type == :POISON
    end
    return custom_pokemon_can_absorb_move?(pkmn, move, move_type)
  end

  #===============================================================================
  # AI_ChooseMove_GenericEffects
  #===============================================================================
  # Aliased to adds score modifier for the Gen 9 abilities and moves.
  #-------------------------------------------------------------------------------
  alias custom_get_score_for_weather get_score_for_weather
  def get_score_for_weather(weather, move_user, starting = false)
    return 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
                @battle.pbCheckGlobalAbility(:CLOUDNINE)
    ret = custom_get_score_for_weather(weather, move_user, starting)
    each_battler do |b, i|
      # Check each battler's abilities/other moves affected by the new weather
      if @trainer.medium_skill? && !b.has_active_item?(:UTILITYUMBRELLA)
        # Abilities
        beneficial_abilities = {
          :Rain       => [:WAYOFSWIFTNESS]
        }[weather]
        if beneficial_abilities && beneficial_abilities.length > 0 &&
           b.has_active_ability?(beneficial_abilities)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
      end
    end
    return ret
  end

end

################################################################################
# 
# Battle::AI::Handlers class changes.
# 
################################################################################

Battle::AI::Handlers::AbilityRanking.add(:GIANTWINGS,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.wingMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ATOMICPUNCH,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:STEEL) || battler.check_for_move { |m| m.punchingMove? }
    next 0
  }
)


################################################################################
# 
# Battle::AI::AIBattler class changes.
# 
################################################################################
class Battle::AI::AIBattler
    # Added Gen 9 base ability ratings
    alias custom_wants_ability? wants_ability?
    def wants_ability?(ability = :NONE)
      Battle::AI::CUSTOM_BASE_ABILITY_RATINGS.each_pair do |val, abilities|
        next if Battle::AI::BASE_ABILITY_RATINGS[val] && Battle::AI::BASE_ABILITY_RATINGS[val].include?(ability)
        Battle::AI::BASE_ABILITY_RATINGS[val] = [] if !Battle::AI::BASE_ABILITY_RATINGS[val]
        abilities.each{|ab|
          Battle::AI::BASE_ABILITY_RATINGS[val].push(ab)
        }
      end
      return custom_wants_ability?(ability)
    end
end