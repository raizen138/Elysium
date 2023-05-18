#===============================================================================
# ■ Fly Animation by KleinStudio
# http://pokemonfangames.com
#===============================================================================
# A.I.R (Update for v20.1)
#V2.0
#===============================================================================

HiddenMoveHandlers::CanUseMove.add(:FLY, proc { |move, pkmn, showmsg|
  next pbCanFly?(pkmn, showmsg)
})

HiddenMoveHandlers::UseMove.add(:FLY,proc { |move, pokemon|
   if $game_temp.fly_destination.nil?
  pbMessage(_INTL("You can't use that here."))
    next false
  end
  if !pbHiddenMoveAnimation(pokemon)
    name = pokemon&.name || $player.name 
    move = :FLY
    pbMessage(_INTL("{1} used {2}!", name, GameData::Move.get(move).name))
  end
  $stats.fly_count += 1
  pbFlyAnimation
  pbFadeOutIn {
    $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
    $game_temp.player_new_x         = $game_temp.fly_destination[1]
    $game_temp.player_new_y         = $game_temp.fly_destination[2]
    $game_temp.player_new_direction = 2
    $game_temp.fly_destination = nil
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbFlyAnimation(false)
  pbEraseEscapePoint
  next true
})
#------------------
class Game_Character
  def setOpacity(value)
    @opacity = value
  end
end
#-------------------
if Show_Gen_4_Bird == false
def pbFlyAnimation(landing=true)
  if landing
    $game_player.turn_left
    pbSEPlay("flybird")
  end
	width  = Settings::SCREEN_WIDTH
	height = Settings::SCREEN_HEIGHT
  @flybird = Sprite.new
  @flybird.bitmap = RPG::Cache.picture("flybird")
  @flybird.ox = @flybird.bitmap.width/2
  @flybird.oy = @flybird.bitmap.height/2
  @flybird.x  = width + @flybird.bitmap.width
  @flybird.y  = height/4
  loop do
    pbUpdateSceneMap
    if @flybird.x > (width / 2 + 10)
      @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      @flybird.y -= (height / 4 - height / 2).div BIRD_ANIMATION_TIME
    elsif @flybird.x <= (width / 2 + 10) && @flybird.x >= 0
      @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      @flybird.y += (height / 4 - height / 2).div BIRD_ANIMATION_TIME
      $game_player.setOpacity(landing ? 0 : 255)
    else
      break
    end
    Graphics.update
  end
  @flybird.dispose
  @flybird = nil
end
else
  def pbFlyAnimation(landing=true)
    if landing
      $game_player.turn_left
      pbSEPlay("flybird")
    end
    width  = Settings::SCREEN_WIDTH
    height = Settings::SCREEN_HEIGHT
    @flybird = Sprite.new
    @flybird.bitmap = RPG::Cache.picture("flybird_gen4")
    @flybird.ox = @flybird.bitmap.width/2
    @flybird.oy = @flybird.bitmap.height/2
    @flybird.x  = width + @flybird.bitmap.width
    @flybird.y  = height/4
    loop do
      pbUpdateSceneMap
      if @flybird.x > (width / 2 + 10)
        @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
        @flybird.y -= (height / 4 - height / 2).div BIRD_ANIMATION_TIME
      elsif @flybird.x <= (width / 2 + 10) && @flybird.x >= 0
        @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
        @flybird.y += (height / 4 - height / 2).div BIRD_ANIMATION_TIME
        $game_player.setOpacity(landing ? 0 : 255)
      else
        break
      end
      Graphics.update
    end
    @flybird.dispose
    @flybird = nil
  end
end