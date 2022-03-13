################################################################################
# Simple Exit Arrows - by Tustin2121
#
# To use, set the graphic of your exit warp event to an arrow with 
# the desired hue and name it "ExitArrow" (without the quotes). 
#
# The below code will do the work of hiding and showing the arrow when needed.
################################################################################
class Game_Player < Game_Character
  # Run when the player turns.
  # The default version of this method is empty, so replacing it outright
  # like this is fine. You may want to double check, just in case, however.
  def pbCheckEventTriggerAfterTurning
    pxCheckExitArrows
  end
end

class Game_Character
  # Add accessors for some otherwise hidden options
  attr_accessor :step_anime
  attr_accessor :direction_fix
end

# Checks if the player is standing next to the exit arrow, facing it.
def pxCheckExitArrows(init=false)
  px = $game_player.x
  py = $game_player.y
  for event in $game_map.events.values
    next if !event.name[/^ExitArrow$/]
    case $game_player.direction
      when 2 #down
        event.transparent = !(px==event.x && py==event.y-1)
      when 8 #up
        event.transparent = !(px==event.x && py==event.y+1)
      when 4 #left
        event.transparent = !(px==event.x+1 && py==event.y)
      when 6 #right
        event.transparent = !(px==event.x-1 && py==event.y)
    end
    if init
      # This homogenizes the Exit Arrows to all act the same, that is
      # a slow flashing arrow. If you want to change the behavior, 
      # change the values below.
      event.move_speed = 1
      event.walk_anime = false
      event.step_anime = true
      event.direction_fix = true
    end
  end
end

# Run on scene change, init them as well
Events.onMapSceneChange+=proc{|sender,e|
  pxCheckExitArrows(true)
}

# Run on every step taken
Events.onLeaveTile+=proc {|sender,e|
  pxCheckExitArrows
}