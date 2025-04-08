#===============================================================================
# EV Selection Scene
#===============================================================================
class PokemonAssignEfforts_Scene
  #---------------------------------------------------------------------------
  # Draw Scene
  #---------------------------------------------------------------------------
  def pbStartScene(pokemon)
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon = pokemon
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Summary/bg_evpage2"))
    @base_color = Color.new(248, 248, 248)
    @shadow_color = Color.new(104, 104, 104)
    @sprites["evssel"] = EVsSelectionSprite.new(@viewport) if !@sprites["evssel"]
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    overlay = @sprites["overlay"].bitmap

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)

    pbDrawEvSelection
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbScene
    @sprites["evssel"].index   = 0
    @sprites["evssel"].z       = 99999
    selev    = 0
    oldselev = 0
    evTotal  = 0
    stat_symbols = [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
    stat = stat_symbols[selev]
    drawSelectedStat(stat, selev, @pokemon.ev[stat] != 0, evTotal < 2)
    @pokemon.ev.each_value { |e| evTotal += 1 if e != 0 }
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        if(evTotal < 2 && evTotal > 0)
          pbMessage(_INTL("You must assign 2 Stats to your Pokémon."))
        else
          pbPlayCloseMenuSE 
          break
        end
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if @pokemon.ev[stat] != 0
          pbChangeEV(@pokemon, stat, 0)
          pbDrawImagePositions(@sprites["overlay"].bitmap, [[_INTL("Graphics/UI/Summary/ev_{1}", stat.to_s.downcase), 243, 97 + (43 * selev), 0, 0, 244, 43]])
          pbDrawTextPositions(@sprites["overlay"].bitmap, [[_INTL("{1}", stat.to_s.gsub('ECIAL_', '. ')), 253, 109 + (43 * selev), 0, @base_color, @shadow_color]])
          evTotal -= 1
        else
          if evTotal < 2
            pbChangeEV(@pokemon, stat, calculateEVsByLevel)
            pbDrawImagePositions(@sprites["overlay"].bitmap, [[_INTL("Graphics/UI/Summary/ev_{1}", stat.to_s.downcase), 243, 97 + (43 * selev), 0, 43, 244, 43]])
            pbDrawTextPositions(@sprites["overlay"].bitmap, [[_INTL("{1}", stat.to_s.gsub('ECIAL_', '. ')), 253, 109 + (43 * selev), 0, @base_color, @shadow_color]])
            evTotal += 1
          else
            pbMessage(_INTL("You can't select more than 2 options."))
          end
        end
        drawSelectedStat(stat, selev, @pokemon.ev[stat] != 0, evTotal < 2)
      elsif Input.trigger?(Input::UP)
        selev -= 1
        selev = 5 if selev < 0
        @sprites["evssel"].index = selev
        stat = stat_symbols[selev]
        drawSelectedStat(stat, selev, @pokemon.ev[stat] != 0, evTotal < 2)
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        selev += 1
        selev = 0 if selev > 5
        @sprites["evssel"].index = selev
        stat = stat_symbols[selev]
        drawSelectedStat(stat, selev, @pokemon.ev[stat] != 0, evTotal < 2)
        pbPlayCursorSE
      end
    end
  end

  #---------------------------------------------------------------------------
  # End Scene
  #---------------------------------------------------------------------------
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  #---------------------------------------------------------------------------
  # Draw Selected Stat
  #---------------------------------------------------------------------------
  def drawSelectedStat(stat, pos, negative = false, change = false)
    overlay = @sprites["overlay"].bitmap
    pbDrawEvSelection
    stataccessor = [:totalhp, :attack, :defense, :spatk, :spdef, :speed]
    textpos = []
    text = ""

    textpos.push([_INTL(stat.to_s.gsub('ECIAL_', '. ')), 26, 324, :left, @base_color, @shadow_color])
    if negative
      text = _INTL("#{@pokemon.send(stataccessor[pos]).to_s} -> #{calculatePossibleStats(@pokemon, stat, 0)}")
      textpos.push([text, 26, 358, :left, Color.new(194, 64, 54), Color.new(169, 131, 127)])
    else
      if change
        text = _INTL("#{@pokemon.send(stataccessor[pos]).to_s} -> #{calculatePossibleStats(@pokemon, stat, calculateEVsByLevel)}")
        textpos.push([text, 26, 358, :left, Color.new(94, 227, 122), Color.new(127, 169, 133)])
      else
        textpos.push([_INTL(@pokemon.send(stataccessor[pos]).to_s), 26, 358, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      end
    end

    pbDrawTextPositions(overlay, textpos)
  end

  #---------------------------------------------------------------------------
  # Draw Pokemon Info
  #---------------------------------------------------------------------------
  def drawPokemonInfo(pkmn)
    imagepos = []
    ballimage = sprintf("Graphics/UI/Summary/icon_ball_%s", pkmn.poke_ball)
    imagepos.push([ballimage, 14, 60])
    textpos = [
      [_INTL("ASSIGN EFFORT VALUES"), 26, 22, :left, @base_color, @shadow_color],
      [pkmn.name, 46, 68, :left, @base_color, @shadow_color]
    ]
    imagepos.push(["Graphics/UI/shiny", 2, 134]) if pkmn.shiny?
    textpos.push([pkmn.level.to_s, 46, 98, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    if pkmn.male?
      textpos.push([_INTL("♂"), 178, 68, :left, Color.new(24, 112, 216), Color.new(136, 168, 208)])
    elsif pkmn.female?
      textpos.push([_INTL("♀"), 178, 68, :left, Color.new(248, 56, 32), Color.new(224, 152, 144)])
    end
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  #---------------------------------------------------------------------------
  # Calculate Possible stats
  #---------------------------------------------------------------------------
  def calculatePossibleStats(pkmn, stat, evvalue)
    base_stats = pkmn.baseStats
    level = pkmn.level
    ivs = pkmn.calcIV
    # Format stat multipliers due to nature
    nature_mod = 100
    this_nature = pkmn.nature
    if this_nature && this_nature.stat_changes.any? { |change| change[0] == stat }
      nature_mod = 100 + this_nature.stat_changes.find { |change| change[0] == stat }[1]
    end
    if stat == :HP
      return 1 if base_stats[stat] == 1   # For Shedinja
      return (((base_stats[stat] * 2) + ivs[stat] + (evvalue / 4)) * level / 100).floor + level + 10
    else
      return (((((base_stats[stat] * 2) + ivs[stat] + (evvalue / 4)) * level / 100).floor + 5) * nature_mod / 100).floor
    end
  end

  #---------------------------------------------------------------------------
  # Calculate EVs based on the level
  #---------------------------------------------------------------------------
  def calculateEVsByLevel
    level = @pokemon.level
    if level >= Settings::LEVEL_MAX_EVS
      return 252
    else
      return (252 / Settings::LEVEL_MAX_EVS * level).floor
    end
  end

  #---------------------------------------------------------------------------
  # Change EV of stat to 252
  #---------------------------------------------------------------------------
  def pbChangeEV(pkmn, stat, value)
    pkmn.ev[stat] = value
    pkmn.calc_stats
    pbUpdate
  end

  #---------------------------------------------------------------------------
  # Update
  #---------------------------------------------------------------------------
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbDrawEvSelection
    overlay = @sprites["overlay"].bitmap
    overlay.clear

    textpos =  []
    imagepos = []
    ev_positions = [
      [:HP, "Graphics/UI/Summary/ev_hp", 243, 96],
      [:ATTACK, "Graphics/UI/Summary/ev_attack", 243, 140],
      [:DEFENSE, "Graphics/UI/Summary/ev_defense", 243, 183],
      [:SPECIAL_ATTACK, "Graphics/UI/Summary/ev_special_attack", 243, 226],
      [:SPECIAL_DEFENSE, "Graphics/UI/Summary/ev_special_defense", 243, 269],
      [:SPEED, "Graphics/UI/Summary/ev_speed", 243, 312]
    ]

    ev_positions.each_with_index do |(symbol, path, x, y), index|
      active = @pokemon.ev[symbol] != 0
      extrahp = (symbol == :HP && active) ? 44 : 43
      extraspd = (symbol == :SPEED && active) ? 44 : 43

      imagepos.push([
          _INTL(path), x, y, 0, 
          active ? extrahp : 0, 
          244, 
          active ? extraspd : 43
      ])

      textpos.push([_INTL("{1}", symbol.to_s.gsub('ECIAL_', '. ')), x + 10, y + 12, 0, @base_color, @shadow_color])
    end

    drawPokemonInfo(@pokemon)
    pbDrawImagePositions(overlay, imagepos)
    pbDrawTextPositions(overlay, textpos)
  end
end


#---------------------------------------------------------------------------
# EV Selection Screen
#---------------------------------------------------------------------------
class PokemonAssignEffortsScreen
  def initialize(scene)
    @scene = scene
  end

  #---------------------------------------------------------------------------
  # EV Selection Screen Start
  #---------------------------------------------------------------------------
  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbScene
    @scene.pbEndScene
  end
end