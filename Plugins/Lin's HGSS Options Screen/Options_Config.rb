#===============================================================================
# * Options Settings
#===============================================================================

module OptionsConfig
  # Change the color of the "Options" text. Change only the numbers to change the colors
  TITLE_BASE = Color.new(248, 248, 248)
  TITLE_SHADOW = Color.new(0, 0, 0)

  # Change the color of the options text. Change only the numbers to change the colors
  TEXT_BASE = Color.new(248, 248, 248)
  TEXT_SHADOW = Color.new(0, 0, 0)

  # Change the color of the name of the selected option. Change only the numbers to change the colors
  NAME_BASE = Color.new(248, 176, 80)
  NAME_SHADOW = Color.new(192, 120, 0)

  # Change the color of the selected value of the option. Change only the numbers to change the colors
  VALUE_BASE = Color.new(248, 136, 128)
  VALUE_SHADOW = Color.new(248, 48, 24)

  # Change the position of the "Options" text
  TITLE_X = 0		# Default: 0
  TITLE_Y = -10		# Default: -10

  # Change the position of the options.
  # It only changes the position of the text window so no individual positioning of the options
  OPTIONS_X = 0		# Default: 0
  OPTIONS_Y = -16	# Default: -16

  # Set to true to have acces to the Controls Screen from the Options Screen
  # Will not work if the plugin isn't instaled
  CONTROLS_IN_OPTIONS = false
end