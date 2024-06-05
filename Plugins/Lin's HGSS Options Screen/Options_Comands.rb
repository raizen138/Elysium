#===============================================================================
# * Options Menu commands
#===============================================================================

MenuHandlers.add(:options_menu, :menu_frame, {
  "name"        => _INTL("Menu Frame"),
  "order"       => 100,
  "type"        => NumberOption,
  "parameters"  => 1..Settings::MENU_WINDOWSKINS.length,
  "description" => _INTL("Choose the appearance of menu boxes. This box will change to show the option."),
  "get_proc"    => proc { next $PokemonSystem.frame },
  "set_proc"    => proc { |value, scene|
    $PokemonSystem.frame = value
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    # Change the windowskin of the options text box to selected one
    scene.sprites["textbox"].setSkin(MessageConfig.pbGetSystemFrame)
  }
})