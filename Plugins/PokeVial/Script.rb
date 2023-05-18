###############################################################################
# POKEVIAL - ADAPTADO POR SKYFLYER
###############################################################################

# VARIABLES QUE SE UTILIZAN (cambiar el número si prefieres usar otras)
USOSACTUALES = 238
MAXIMOUSOS = 239

ItemHandlers::UseFromBag.add(:POKEVIAL,proc{|item|
  if $game_variables[USOSACTUALES]==1 # Frase en singular
    Kernel.pbMessage(_INTL("Tienes {1} curación disponible de un máximo de {2}.", 
      $game_variables[USOSACTUALES], $game_variables[MAXIMOUSOS]))
  elsif $game_variables[USOSACTUALES]>1 # Frase en plural
    Kernel.pbMessage(_INTL("Tienes {1} curaciones disponibles de un máximo de {2}.", 
      $game_variables[USOSACTUALES], $game_variables[MAXIMOUSOS]))
  else # Si no te quedan curaciones
    Kernel.pbMessage(_INTL("El Pokévial está vacío. Recárgalo en el Centro Pokémon.", 
      $game_variables[MAXIMOUSOS]))
    next 0
  end
  if Kernel.pbConfirmMessage(_INTL("¿Curar a tu equipo con el Pokévial?"))
    # Si le dices que sí, te cura todo el equipo y elimina una curación del vial.
    for i in $Trainer.party
      i.heal
    end
    Kernel.pbMessage(_INTL("¡Tu equipo ha sido curado!"))
    # Quitamos un uso del vial al curarte al equipo.
    $game_variables[USOSACTUALES] = $game_variables[USOSACTUALES]-1
  end
  next 0
  #next 1
})