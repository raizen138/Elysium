#===============================================================================
# Party Ball
#===============================================================================
if Settings::SHOW_PARTY_BALL
  class PokemonPartyPanel < SpriteWrapper
    alias enhanced_initialize initialize
    def initialize(*args)
      enhanced_initialize(*args)
      GameData::Item.each do |ball|
        next if !ball.is_poke_ball?
        sprite = "Graphics/Plugins/Enhanced UI/Party Ball/#{ball.id}"
        @ballsprite.addBitmap("#{ball.id}_desel", sprite)
        @ballsprite.addBitmap("#{ball.id}_sel", sprite + "_sel")
      end
      refresh
    end
	
    alias enhanced_refresh_ball_graphic refresh_ball_graphic
    def refresh_ball_graphic
      enhanced_refresh_ball_graphic
      if @ballsprite && !@ballsprite.disposed?
        ball = @pokemon.poke_ball
        path = "Graphics/Plugins/Enhanced UI/Party Ball/#{ball}"
        ball_sel   = pbResolveBitmap(path + "_sel") ? "#{ball}_sel"   : "sel"
        ball_desel = pbResolveBitmap(path)          ? "#{ball}_desel" : "desel"
        @ballsprite.changeBitmap((self.selected) ? ball_sel : ball_desel)
      end
    end
  end
end


#===============================================================================
# Shiny Leaf
#===============================================================================
if Settings::SUMMARY_SHINY_LEAF
  class PokemonSummary_Scene
    alias enhanced_drawPage drawPage
    def drawPage(page)
      enhanced_drawPage(page)
      overlay = @sprites["overlay"].bitmap
	  coords = (PluginManager.installed?("BW Summary Screen")) ? [Graphics.width - 18, 114] : [182, 124]
      pbDisplayShinyLeaf(@pokemon, overlay, coords[0], coords[1])
    end
  end
end

#-------------------------------------------------------------------------------
# Adds Shiny Leaf to Pokemon data.
#-------------------------------------------------------------------------------
class Pokemon
  def shiny_leaf;   return @shiny_leaf || 0; end
  def shiny_crown?; return @shiny_leaf == 6; end
    
  def shiny_leaf?
    return false if @shiny_leaf.nil?
    return @shiny_leaf > 0
  end
  
  def shiny_leaf=(value)
    value = (value < 0) ? 0 : (value > 6) ? 6 : value
    @shiny_leaf = (value)
  end
  
  alias enhanced_initialize initialize  
  def initialize(*args)
    @shiny_leaf = 0
    enhanced_initialize(*args)
  end
end

#-------------------------------------------------------------------------------
# Displays a Pokemon's collected Shiny Leaves on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# If "vertical" is set to true, Shiny Leaves will be displayed in a vertically
# stacked layout. Otherwise, Shiny Leaves will be displayed horizontally. This
# has no effect on how the Shiny Leaf Crown is displayed.
#-------------------------------------------------------------------------------
def pbDisplayShinyLeaf(pokemon, overlay, xpos, ypos, vertical = false)
  imagepos = []
  path = "Graphics/Plugins/Enhanced UI/shiny_"
  if pokemon.shiny_crown?
    imagepos.push([sprintf(path + "crown"), xpos - 18, ypos - 3])
  elsif pokemon.shiny_leaf?
    offset_x = (vertical) ? 0  : 10
    offset_y = (vertical) ? 10 : 0
    pokemon.shiny_leaf.times do |i|
      imagepos.push([sprintf(path + "leaf"), xpos - (i * offset_x), ypos + (i * offset_y)])
    end
  end  
  pbDrawImagePositions(overlay, imagepos)
end

#-------------------------------------------------------------------------------
# Adds Shiny Leaf debug tools to the "cosmetic" section in a Pokemon's debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :set_shiny_leaf, {
  "name"   => _INTL("Set shiny leaf"),
  "parent" => :cosmetic,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Has shiny crown."), _INTL("Has shiny leaf x#{pkmn.shiny_leaf}.")][pkmn.shiny_crown? ? 0 : 1]
      cmd = screen.pbShowCommands(msg, [
           _INTL("Set leaf"),
           _INTL("Set crown"),
           _INTL("Reset")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Set Leaf
        params = ChooseNumberParams.new
        params.setRange(0, 6)
        params.setDefaultValue(pkmn.shiny_leaf)
        leafcount = pbMessageChooseNumber(
          _INTL("Set {1}'s leaf count (max. 6).", pkmn.name), params) { screen.pbUpdate }
        pkmn.shiny_leaf = leafcount
      when 1   # Set Crown
        pkmn.shiny_leaf = 6
      when 2   # Reset
        pkmn.shiny_leaf = 0
      end
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})


#===============================================================================
# IV Star Ratings
#===============================================================================
if Settings::SUMMARY_IV_RATINGS
  class PokemonSummary_Scene
    alias enhanced_drawPageThree drawPageThree
    def drawPageThree
      enhanced_drawPageThree
      overlay = @sprites["overlay"].bitmap
	  coords = (PluginManager.installed?("BW Summary Screen")) ? [110, 82] : [465, 82]
      pbDisplayIVRating(@pokemon, overlay, coords[0], coords[1])
    end
	
	def pbDisplayIVRating(*args)
	  return if args.length == 0
	  pbDisplayIVRatings(*args)
	end
  end
end

#-------------------------------------------------------------------------------
# Displays star ratings for a Pokemon's IV's on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# If "horizontal" is set to true, IV stars will be displayed in a horizontal
# layout, side by side. Otherwise, IV stars will be displayed vertically and
# spaced out in a way to account for the stat display in the Summary.
#-------------------------------------------------------------------------------
def pbDisplayIVRatings(pokemon, overlay, xpos, ypos, horizontal = false)
  imagepos = []
  path  = "Graphics/Plugins/Enhanced UI/"
  case Settings::IV_DISPLAY_STYLE
  when 0 then path += "iv_stars"
  when 1 then path += "iv_letters"
  end
  maxIV = Pokemon::IV_STAT_LIMIT
  offset_x = (horizontal) ? 16 : 0
  offset_y = (horizontal) ? 0  : 32
  i = 0
  GameData::Stat.each_main do |s|
    stat = pokemon.iv[s.id]
    case stat
    when maxIV     then icon = 5  # 31 IV
    when maxIV - 1 then icon = 4  # 30 IV
    when 0         then icon = 0  #  0 IV
    else
      if stat > (maxIV - (maxIV / 4).floor)
        icon = 3 # 25-29 IV
      elsif stat > (maxIV - (maxIV / 2).floor)
        icon = 2 # 16-24 IV
      else
        icon = 1 #  1-15 IV
      end
    end
    imagepos.push([path, xpos + (i * offset_x), ypos + (i * offset_y), icon * 16, 0, 16, 16])
	if s.id == :HP && !horizontal
	  ypos += (PluginManager.installed?("BW Summary Screen")) ? 18 : 12 
	end
    i += 1
  end
  pbDrawImagePositions(overlay, imagepos)
end


#===============================================================================
# Egg Groups
#===============================================================================
if Settings::SUMMARY_EGG_GROUPS
  class PokemonSummary_Scene
    alias enhanced_drawPageTwo drawPageTwo
    def drawPageTwo
      enhanced_drawPageTwo
      overlay = @sprites["overlay"].bitmap
	  coords = (PluginManager.installed?("BW Summary Screen")) ? [162, 326] : [364, 338]
	  vertical = (PluginManager.installed?("BW Summary Screen")) ? true : false
      pbDisplayEggGroups(@pokemon, overlay, coords[0], coords[1], "Egg Groups:", vertical)
    end
  end
end

if Settings::POKEDEX_EGG_GROUPS
  class PokemonPokedexInfo_Scene
    alias enhanced_drawPageInfo drawPageInfo
    def drawPageInfo
      enhanced_drawPageInfo
	  return if !$player.owned?(@species)
      overlay = @sprites["overlay"].bitmap
      species_data = GameData::Species.get_species_form(@species, @form)
      pbDisplayEggGroups(species_data, overlay, 148, 204, true)
    end
  end
end

#-------------------------------------------------------------------------------
# Displays a Pokemon's Egg Groups on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# "pokemon" can be set to either a Pokemon object, or a GameData::Species.
#
# If "showDisplay" is set as a string, that text will be displayed in front of the
# Egg Group icons. If "showDisplay" is set to true, it will instead add a background
# behind the Egg Group icons (used for the Pokedex). Otherwise, no additional
# displays will appear.
#
# If "vertical" is set to true, Egg Group icons will be displayed in a vertically
# stacked layout, if the Pokemon belongs to more than one Egg Group. Otherwise,
# Egg Groups will be displayed horizontally from each other.
#-------------------------------------------------------------------------------
def pbDisplayEggGroups(pokemon, overlay, xpos, ypos, showDisplay = nil, vertical = false)
  egg_groups = egg_group_hash
  compat  = (pokemon.is_a?(Pokemon)) ? pokemon.species_data.egg_groups : GameData::Species.get(pokemon).egg_groups
  compat1 = compat[0]
  compat2 = compat[1] || compat[0]
  eggGroupbitmap = AnimatedBitmap.new(_INTL("Graphics/Plugins/Enhanced UI/egg_groups"))
  if pokemon.is_a?(Pokemon)
    isGenderless = (pokemon.genderless? && !pokemon.isSpecies?(:DITTO))
  else
    isGenderless = (GameData::Species.get(pokemon).gender_ratio == :Genderless && pokemon != :DITTO)
  end
  if showDisplay.is_a?(String)
    if egg_groups[compat1] > 14 || egg_groups[compat2] > 14
      base   = Color.new(250, 213, 165)
      shadow = Color.new(204, 85, 0)
    elsif PluginManager.installed?("BW Summary Screen")
	  base   = Color.new(255, 255, 255)
      shadow = Color.new(123, 123, 123)
	else
      base   = Color.new(64, 64, 64)
      shadow = Color.new(176, 176, 176)
    end
    textpos = [ [_INTL("#{showDisplay}"), xpos - 130, ypos + 2, 0, base, shadow] ]
    pbDrawTextPositions(overlay, textpos)
  elsif showDisplay
    imagepos = [ [sprintf("Graphics/Plugins/Enhanced UI/dex_bg"), xpos - 6, ypos - 14] ]
    pbDrawImagePositions(overlay, imagepos)
  end
  if isGenderless && !compat.include?(:Undiscovered)
    xpos += 34 if !vertical
    eggGroupRect = Rect.new(0, egg_groups[:Unknown] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroupRect)
  elsif compat1 == compat2
    xpos += 34 if !vertical
    eggGroupRect = Rect.new(0, egg_groups[compat1] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroupRect)
  else
    offset_x = (vertical) ? 0  : 68
    offset_y = (vertical) ? 28 : 0
    eggGroup1Rect = Rect.new(0, egg_groups[compat1] * 28, 64, 28)
    eggGroup2Rect = Rect.new(0, egg_groups[compat2] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroup1Rect)
    overlay.blt(xpos + offset_x, ypos + offset_y, eggGroupbitmap.bitmap, eggGroup2Rect)
  end
end


#===============================================================================
# Battle Move Window
#===============================================================================
class Battle::Scene
  alias enhanced_pbInitSprites pbInitSprites
  def pbInitSprites
    enhanced_pbInitSprites
    idx = 0
    @moveUIToggle = false
    @sprites["moveinfo"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["moveinfo"].z = 200
    @sprites["moveinfo"].visible = @moveUIToggle
    pbSetSmallFont(@sprites["moveinfo"].bitmap)
    @moveUIOverlay = @sprites["moveinfo"].bitmap
    @targetIcons = []
    @battle.allBattlers.each do |b|
      next if b.index.even?
      @sprites["effectiveness_icon#{b.index}"] = PokemonIconSprite.new(b.pokemon, @viewport)
      @sprites["effectiveness_icon#{b.index}"].visible = false
      @sprites["effectiveness_icon#{b.index}"].setOffset(PictureOrigin::LEFT)
      @sprites["effectiveness_icon#{b.index}"].z = 201
      @sprites["effectiveness_icon#{b.index}"].x = Graphics.width - 64 - (idx * 64)
      @sprites["effectiveness_icon#{b.index}"].y = 68
      idx += 1
    end
  end
  
  #-----------------------------------------------------------------------------
  # Refreshes Pokemon icons for effectiveness display.
  #-----------------------------------------------------------------------------
  def pbUpdateTargetIcons
    @battle.allBattlers.each do |b|
      next if b.index.even?
      if b && !b.fainted?
        @sprites["effectiveness_icon#{b.index}"].pokemon = b.pokemon
        @sprites["effectiveness_icon#{b.index}"].visible = @moveUIToggle
      else
        @sprites["effectiveness_icon#{b.index}"].visible = false
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the visibility of the move window.
  #-----------------------------------------------------------------------------
  def pbToggleMoveInfo(battler, index = 0)
    @moveUIToggle = !@moveUIToggle
    (@moveUIToggle) ? pbSEPlay("GUI party switch") : pbPlayCloseMenuSE
    @sprites["moveinfo"].visible = @moveUIToggle
    pbToggleFocusPanel(false) if PluginManager.installed?("Focus Meter System")
    pbUpdateTargetIcons
    pbUpdateMoveInfoWindow(battler, index)
  end
  
  #-----------------------------------------------------------------------------
  # Draws the move window.
  #-----------------------------------------------------------------------------
  def pbUpdateMoveInfoWindow(battler, index)
    @moveUIOverlay.clear
    return if !@moveUIToggle
    xpos = 0
    ypos = 94
    move = battler.moves[index]
    path = "Graphics/Plugins/Enhanced UI/"
    #---------------------------------------------------------------------------
    # Draws the menu, and icons for move type and category.
    #---------------------------------------------------------------------------
    typenumber = GameData::Type.get(move.type).icon_position
    imagePos = [
      [path + "move_window",         xpos, ypos],
      ["Graphics/Pictures/types",    xpos + 272, ypos + 4, 0, typenumber * 28, 64, 28],
      ["Graphics/Pictures/category", xpos + 336, ypos + 4, 0, move.category * 28, 64, 28]
    ]
    #---------------------------------------------------------------------------
    # Draws the effectiveness display for each opponent.
    #---------------------------------------------------------------------------
    idx = 0
    @battle.allBattlers.each do |b|
      next if b.index.even?
      if b && !b.fainted? && move.category < 2
        unknown_species = ($player.pokedex.battled_count(b.species) == 0 && !$player.pokedex.owned?(b.species))
        value = Effectiveness.calculate(move.type, b.types[0], b.types[1])
        if unknown_species                             then effct = 0
        elsif Effectiveness.ineffective?(value)        then effct = 1
        elsif Effectiveness.not_very_effective?(value) then effct = 2
        elsif Effectiveness.super_effective?(value)    then effct = 3
        else effct = 4
        end
        imagePos.push([path + "move_effectiveness", Graphics.width - 64 - (idx * 64), ypos - 76, effct * 64, 0, 64, 76])
        @sprites["effectiveness_icon#{b.index}"].visible = true
      else
        @sprites["effectiveness_icon#{b.index}"].visible = false
      end
      idx += 1
    end
    #---------------------------------------------------------------------------
    # Draws icons for each relevant move flag.
    #---------------------------------------------------------------------------
    flagX = xpos + 5
    flagY = ypos + 32
    flagIcons = []
    if PluginManager.installed?("ZUD Mechanics")
      if move.zMove?
        flagIcons.push([path + "move_icons", flagX + (flagIcons.length * 26), flagY, 0 * 26, 0, 26, 28])
      elsif move.maxMove?
        flagIcons.push([path + "move_icons", flagX + (flagIcons.length * 26), flagY, 1 * 26, 0, 26, 28])
      end
    end
    if GameData::Target.get(move.target).targets_foe
      flagIcons.push([path + "move_icons", flagX + (flagIcons.length * 26), flagY, 2 * 26, 0, 26, 28]) if !move.flags.include?("CanProtect")
      flagIcons.push([path + "move_icons", flagX + (flagIcons.length * 26), flagY, 3 * 26, 0, 26, 28]) if !move.flags.include?("CanMirrorMove")
    end
    move.flags.each do |flag|
      idx = -1
      case flag
      when "Contact"             then idx = 4
      when "TramplesMinimize"    then idx = 5
      when "HighCriticalHitRate" then idx = 6
      when "ThawsUser"           then idx = 7
      when "Sound"               then idx = 8
      when "Punching"            then idx = 9
      when "Biting"              then idx = 10
      when "Bomb"                then idx = 11
      when "Pulse"               then idx = 12
      when "Powder"              then idx = 13
      when "Dance"               then idx = 14
      end
      next if idx < 0
      flagIcons.push([path + "move_icons", flagX + (flagIcons.length * 26), flagY, idx * 26, 0, 26, 28])
    end
    imagePos += flagIcons
    pbDrawImagePositions(@moveUIOverlay, imagePos)
    #---------------------------------------------------------------------------
    # Sets up move data.
    #---------------------------------------------------------------------------
    base = Color.new(232, 232, 232)
    shadow = Color.new(72, 72, 72)
    raised_base = Color.new(50, 205, 50)
    raised_shadow = Color.new(9, 121, 105)
    lowered_base = Color.new(248, 72, 72)
    lowered_shadow = Color.new(136, 48, 48)
    power = (move.baseDamage == 0) ? "---" : (move.baseDamage == 1) ? "???" : move.baseDamage.to_s
    accuracy = (move.accuracy == 0) ? "---" : move.accuracy.to_s
    effectrate = (move.addlEffect == 0) ? "---" : [:ICEFANG, :FIREFANG, :THUNDEFANG].include?(move.id) ? "10%" : move.addlEffect.to_s + "%"
    dmg_base = acc_base = eff_base = base
    dmg_shadow = acc_shadow = eff_shadow = shadow
    #---------------------------------------------------------------------------
    # Adjusts color of move attributes if affected by Strong/Agile styles.
    #---------------------------------------------------------------------------
    if PluginManager.installed?("PLA Battle Styles") && move.mastered?
      case battler.style_trigger
      when 1
        if move.baseDamage > 1
          dmg_base = raised_base
          dmg_shadow = raised_shadow
        end
        if ![0, 100].include?(move.old_accuracy)
          acc_base = raised_base
          acc_shadow = raised_shadow
        end
        if ![0, 100].include?(move.old_addlEffect)
          eff_base = raised_base
          eff_shadow = raised_shadow
        end
      when 2
        if move.baseDamage > 1 
          dmg_base = lowered_base
          dmg_shadow = lowered_shadow
        end
      end
    end
    #---------------------------------------------------------------------------
    # Draws move data text.
    #---------------------------------------------------------------------------
    textPos = [
      [move.name,       xpos + 10,            ypos + 8,  0, base, shadow],
      [_INTL("Pow:"),   Graphics.width - 86,  ypos + 10, 2, base, shadow],
      [_INTL("Acc:"),   Graphics.width - 86,  ypos + 39, 2, base, shadow],
      [_INTL("Effct:"), xpos + 287,           ypos + 39, 0, base, shadow],
      [power,           Graphics.width - 34,  ypos + 10, 2, dmg_base, dmg_shadow],
      [accuracy,        Graphics.width - 34,  ypos + 39, 2, acc_base, acc_shadow],
      [effectrate,      Graphics.width - 146, ypos + 39, 2, eff_base, eff_shadow]
    ]
    if PluginManager.installed?("ZUD Mechanics") && move.zMove? && move.category == 2
      if GameData::PowerMove.stat_booster?(move.id)
        stats, stage = GameData::PowerMove.stat_with_stage(move.id)
        statname = (stats.length > 1) ? "stats" : GameData::Stat.get(stats.first).name
        case stage
        when 3 then boost = " drastically"
        when 2 then boost = " sharply"
        else        boost = ""
        end
        text = _INTL("Raises the user's #{statname}#{boost}.")
      elsif GameData::PowerMove.boosts_crit?(move.id)  then text = _INTL("Raises the user's critical hit rate.")
      elsif GameData::PowerMove.resets_stats?(move.id) then text = _INTL("Resets the user's lowered stat stages.")
      elsif GameData::PowerMove.heals_self?(move.id)   then text = _INTL("Fully restores the user's HP.")
      elsif GameData::PowerMove.heals_switch?(move.id) then text = _INTL("Fully restores an incoming Pokémon's HP.")
      elsif GameData::PowerMove.focus_user?(move.id)   then text = _INTL("The user becomes the center of attention.")
      end
      textPos.push(["Z-Power: #{text}", xpos + 10, ypos + 128, 0, raised_base, raised_shadow]) if text
    end
    pbDrawTextPositions(@moveUIOverlay, textPos)
    drawTextEx(@moveUIOverlay, xpos + 10, ypos + 70, Graphics.width - 10, 2, GameData::Move.get(move.id).description, base, shadow)
  end
end