#===============================================================================
# * Controls Screen Settings
#===============================================================================

module OverConfig
  # Change the name of the background if you want it to be diferent than the options screen.
  # Note: It has to be in the pictures folder
  BACKGROUND = "optionsbg"

  # Change the color of the "Controls" text. Change only the numbers to change the colors
  TITLE_BASE = Color.new(248, 248, 248)
  TITLE_SHADOW = Color.new(0, 0, 0)

  # Change the color of the name of the options. Change only the numbers to change the colors
  NAME_BASE = Color.new(248, 248, 248)
  NAME_SHADOW = Color.new(0, 0, 0)

  # Change the color of the value of the option. Change only the numbers to change the colors
  VALUE_BASE = Color.new(248,136,128)
  VALUE_SHADOW = Color.new(248,48,24)

  # Change the position of the "Controls" text
  TITLE_X = 0		# Default: 0
  TITLE_Y = -10		# Default: -10

  # Change the position of the controls
  # It only changes the position of the text window so no individual positioning of the controls
  CONTROL_X = 0		# Default: 0
  CONTROL_Y = -16	# Default: -16
end