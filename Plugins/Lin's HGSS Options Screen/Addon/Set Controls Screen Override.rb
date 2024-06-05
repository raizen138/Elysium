#===============================================================================
# * Set the Controls Screen Override - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It changes the Controls Screen to match the Options Screen.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

if PluginManager.installed?("Set the Controls Screen")
class Window_PokemonControls < Window_DrawableCommand
  def initialize(controls,x,y,width,height)
    @controls = controls
    @name_base_color   = OverConfig::NAME_BASE
    @name_shadow_color = OverConfig::NAME_SHADOW
    @sel_base_color    = OverConfig::VALUE_BASE
    @sel_shadow_color  = OverConfig::VALUE_SHADOW
    @reading_input = false
    @changed = false
    super(x,y,width,height)
  end
end

class PokemonControls_Scene
  def start_scene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundOrColoredPlane(@sprites, "bg", "optionsbg", Color.new(192, 200, 208), @viewport)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/OverConfig::BACKGROUND")
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Controls"), OverConfig::TITLE_X, OverConfig::TITLE_Y, Graphics.width, 64, @viewport
    )
    @sprites["title"].back_opacity = 0
    @sprites["title"].baseColor   = OverConfig::TITLE_BASE
    @sprites["title"].shadowColor = OverConfig::TITLE_SHADOW
    @sprites["textbox"]=pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    game_controls = $PokemonSystem.game_controls.map{|c| c.clone}
    @sprites["controlwindow"]=Window_PokemonControls.new(
      game_controls,OverConfig::CONTROL_X,-16 +64 + OverConfig::CONTROL_Y,Graphics.width,
      Graphics.height-(-16 +64 -16)-@sprites["textbox"].height
    )
    @sprites["controlwindow"].viewport=@viewport
    @sprites["controlwindow"].visible=true
    @sprites["controlwindow"].back_opacity = 0
    @changed = false
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { update }
  end
end
end