#######################################################################
# Sistema de gestión de logros y visualización en un interfaz de grid #
#                Script original : Polectron y Caeles                 #
#                    Editado por : Bezier                             #
#######################################################################
# Define tus LOGROS en el apartado correspondiente de este script     #
# Puedes configurar el interfaz cambiando las CONSTANTES              #
#                                                                     #
# Para mostrar el interfaz de logros hay que llamar al script:        #
#   Logros_Scene.new                                                  #
#                                                                     #
# Para consultar o modificar el estado de un logro:                   #
#   Devuelve el estado de un logro                                    #
#     getLogro(indice)                                                #
#   Cambia el estado de un logro                                      #
#     setLogro(indice, nuevoEstado)                                   #
# Los valores de los estados de logro está definidos en este script   #
#######################################################################

######## CONSTANTES ########
NUMPRIMERSWITCH = 80

FONDO = "fondo"                     # Nombre de la imagen que contiene el fondo. Si no se usa imagen escribir nil (sin comillas)
NOMBREOCULTO = "???"               # Nombre para logros ocultos
DESCOCULTO = "Hidden" # Descripción para logros ocultos
OCULTO = "hidden"                   # Imagen para logros ocultos

ICONOSPORFILA = 5 # Número de iconos por cada fila
NUMFILAS = 3      # Número de filas
ICONO_W = 74      # Ancho del icono de logro
ICONO_H = 74      # Alto del icono de logro
ESPACIADOX = 10   # Espacio entre iconos en horizontal
ESPACIADOY = 8    # Espacio entre iconos en vertical
MARGENX = 20      # Margen con los bordes en horizontal
MARGENY = 20      # Margen con los bordes en vertical

SLIDERRANGO = [73,183] # Rango de movimiento del slider

COLORBASE = MessageConfig::DARK_TEXT_MAIN_COLOR       # Color base del texto
COLORSOMBRA = MessageConfig::DARK_TEXT_SHADOW_COLOR   # Color para la sombra del texto
COLORCOMPLETADO = Color.new(100, 250, 75) # Color para el nombre de logro completado

######## LOGROS ########

# Estados de los logros (no editar si no se modifica el script)
LOGRO_OCULTO = 1      # El logro no está disponible
LOGRO_ACTIVO = 2      # El logro no se ha completado
LOGRO_COMPLETADO = 3  # El logro se ha completado

# Definición de los logros dispobibles en el juego.
# Formato de cada logro
# ["Nombre", "Descripción", Estado_inicial (Opcional)]
#   Estado_inicial = Estado inicial del logro. Si no se indica, usa el valor de LOGRO_ACTIVO por defecto.
# La imágen del logro se compondrá con el índice del logro. El primer logro, con índice 0, cargará la imágen 0.png, si no está oculto
LOGROS = [
  ["First Steps", "Obtain your first Pokémon"],
  ["Rock Solid", "Defeat Brock for the Boulder Badge."],
  ["Constant Flux", "Defeat Misty for the Cascade Badge."],
  ["Logro4", "Defeat Lt. Surge for the Thunder Badge."],
  ["Logro5", "Defeat Erika for the Rainbow Badge."],
  ["Logro6", "Defeat Janine for the Soul Badge."],
  ["Logro7", "Defeat Sabrina for the Marsh Badge."],
  ["Logro8", "Defeat Blaine for the Volcano Badge. Y toca probar a ver si funciona esto del scroll o ya no"],
  ["Logro9", "Defeat Giovanni for the Earth Badge.", LOGRO_OCULTO],
  ["Shiny!", "Encounter your first shiny Pokémon", LOGRO_OCULTO],
  ["Logro11", "Descripción corta de logro 11", LOGRO_OCULTO],
  ["Logro12", "Descripción corta de logro 12", LOGRO_OCULTO],
]

# Devuelve el estado del logro iésimo o -1 si no existe el logro
def getLogro(i)
  save_data = getLogrosFile
  return (i >= 0 && i < save_data.size) ? save_data[i] : -1
end
# Devuelve true si ha cambiado el estado del logro, false en caso contrario
def setLogro(i, status)
  save_data = getLogrosFile
  if (i >= 0 && i < save_data.size)
    save_data[i] = status
    return true
  end
  return false
end

def getLogrosFile
	if safeExists?("Data/PersistentSwitches.rxdata")
		pSwitches = load_data("Data/PersistentSwitches.rxdata")
    lSwitches = pSwitches[NUMPRIMERSWITCH...NUMPRIMERSWITCH + LOGROS.size]
		return lSwitches
	else
		initSwitches = []
		File.open("Data/PersistentSwitches.rxdata", "wb") { |f| Marshal.dump(initSwitches, f) }
		pSwitches = load_data("Data/PersistentSwitches.rxdata")
    lSwitches = pSwitches[NUMPRIMERSWITCH...NUMPRIMERSWITCH + LOGROS.size]
		return lSwitches
	end
end

######## ESCENA ########

# Sprite de logro 
class LogroIcon < SpriteWrapper
  attr_reader :index

  def initialize(viewport, index, status)
    super(viewport)
    @name = status != LOGRO_OCULTO ? LOGROS[index][0] : "???"
    @desc = status != LOGRO_OCULTO ? LOGROS[index][1] : ""
    @status = status
    case status
    when LOGRO_OCULTO
      self.bitmap = Bitmap.new("Graphics/Pictures/Logros/img/hidden")
    when LOGRO_ACTIVO
      self.bitmap = File.exists?("Graphics/Pictures/Logros/img/#{index}.png") ? Bitmap.new("Graphics/Pictures/Logros/img/#{index}") : Bitmap.new("Graphics/Pictures/Logros/img/hidden")
    else LOGRO_COMPLETADO
      self.bitmap = File.exists?("Graphics/Pictures/Logros/img/#{index}c.png") ? Bitmap.new("Graphics/Pictures/Logros/img/#{index}c") : Bitmap.new("Graphics/Pictures/Logros/img/hidden")
    end
    @index = index
  end

  def name
    return @name
  end
  def desc
    return @desc
  end
  def status
    return @status
  end
end

# UI para mostrar el estado de los logros
class Logros_Scene

  def initialize
    @logros = []

    @indexSel = 0           # Índice del logro seleccionado
    @lastDiagonalIndex = 0  # Índice del logro anterior cuando se hace un cambio de fila hacia abajo y se selecciona en diagonal el último icono de la última fila
    @logrosOffset = 0       # Desplazamiento de los logros al hacer scroll
    @currentRow = 0         # Fila actual

    @descOffset = 0         # Scroll para el texto de descripción

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Fondo
    @sprites["bg"] = Sprite.new(@viewport)
    if !FONDO
        @sprites["bg"].bitmap = RPG::Cache.picture("helpbg")
    else
        @sprites["bg"].bitmap = RPG::Cache.picture("Logros/"+FONDO)
    end

    # Slider de la barra de scroll
    @sprites["slider"] = Sprite.new(@viewport)
    @sprites["slider"].bitmap = RPG::Cache.picture("Logros/slider")
    @sprites["slider"].x = 453
    @sprites["slider"].y = SLIDERRANGO[0]
    @sliderStep = 0         # Movimiento del slider para cada cambio de fila

    # Carga los sprites de los logros y cuenta el total de filas para calcular el paso de slider
    lasty = -1
    totalfilas = 0
    for index in 0...LOGROS.size
      completado = checkPersistentSwitch(NUMPRIMERSWITCH + index)
      if completado
        isCompleted = LOGRO_COMPLETADO
      elsif LOGROS[index].size == 2
        isCompleted = LOGRO_ACTIVO
      else
        isCompleted = LOGRO_OCULTO
      end
      logroi = LogroIcon.new(@viewport, index, isCompleted)
      pos = getInitialPos(index)
      logroi.x = pos[0]
      logroi.y = pos[1]
      logroi.visible = pos[2] < NUMFILAS
      @logros.push(logroi)
      @sprites["logro#{index}"] = logroi
      if lasty < logroi.y
        lasty = logroi.y
        totalfilas += 1
      end
    end
    if totalfilas > 0
      @sliderStep = (SLIDERRANGO[1] - SLIDERRANGO[0]) / (totalfilas - 1)
    end

    # Fondo para la caja de texto
    @sprites["textbox"] = Sprite.new(@viewport)
    @sprites["textbox"].bitmap = RPG::Cache.picture("Logros/textbox2")
    @sprites["textbox"].x = 20
    @sprites["textbox"].y = 268

    # Overlay donde se pintan los textos (en la versión por defecto se usa solo para el nombre del logro)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(@overlay)

    # Overlay adaptado a la caja de texto para pintar la descripción y poder hacer scroll de texto en una descripción larga
    @sprites["description"] = BitmapSprite.new(468, 62, @viewport)
    @sprites["description"].x = 30
    @sprites["description"].y = 308
    @overlayDesc = @sprites["description"].bitmap
    @maxheight = @sprites["description"].bitmap.height - 4
    pbSetSystemFont(@overlayDesc)

    # Sprite con el selector de logro
    @sprites["selector"] = Sprite.new(@viewport)
    @sprites["selector"].bitmap = RPG::Cache.picture("/Logros/selector")
    @selLTCorner = getInitialPos(0)
    @sprites["selector"].x = @selLTCorner[0] - 4
    @sprites["selector"].y = @selLTCorner[1] - 4
    @selMinY = getFilaY(0)
    @selMaxY = getFilaY(NUMFILAS - 1)

    pbUpdate
  end

  # Devuelve la posición de la fila en base a la configuración del interfaz
  def getFilaY(fila); return MARGENY + (ICONO_H + ESPACIADOY) * fila; end

  # Devuelve un array con las coordenadas [x, y] de un logro según el índice y en base a la configuración
  def getInitialPos(index)
    index = @logros.size if index >= @logros.size
    x = MARGENX + (ICONO_W + ESPACIADOX) * (index % ICONOSPORFILA)
    fila = (index / ICONOSPORFILA).floor
    y = getFilaY(fila)
    return [x,y,fila]
  end

  # Mueve los logros en vertical, mostrando y ocultando los que quedan fuera del área visible
  def moveLogros(y)
    for l in @logros
      l.y += y
      l.visible = l.y >= getFilaY(0) && l.y <= getFilaY(NUMFILAS - 1)
    end
  end

  # Función con el bucle principal
  # Gestiona los inputs para mover la selección y cambiar la vista
  def pbUpdate
    showTexts(0)
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B)

      if @logros.size > 0
        # Selección hacia abajo, Input::DOWN cambia a la fila inferior y Input::R cambia a la página siguiente (salta tantas filas como indique NUMFILAS)
        if Input.trigger?(Input::DOWN) || Input.trigger?(Input::R)
          numsalto = 1
          numsalto = NUMFILAS if Input.trigger?(Input::R)
          numsalto.times do
            salto = ICONOSPORFILA
            # No puede mover hacia abajo. Prueba si se puede diagonal al último icono de la siguiente fila
            if @indexSel + salto > @logros.size - 1 && @indexSel % ICONOSPORFILA > 0
              rest = (@logros.size - 1) - @indexSel # Logros que faltan hasta el final

              # Hay salto de línea en diagonal
              if (@indexSel % ICONOSPORFILA) + rest > ICONOSPORFILA 
                while @indexSel + salto > @logros.size - 1 && salto > 0
                  salto -= 1
                end
                if @indexSel + salto <= @logros.size - 1 && salto > 0 &&
                  (@indexSel % ICONOSPORFILA) + 1 + salto > ICONOSPORFILA
                  @lastDiagonalIndex = @indexSel
                end
              end
            end
            if @indexSel + salto <= @logros.size - 1 && salto > 0
              @descOffset = 0
              @indexSel += salto
              if @currentRow + 1 < NUMFILAS
                @currentRow += 1
                @sprites["selector"].y = getFilaY(@currentRow) - 4
              else
                moveLogros(-(ICONO_H + ESPACIADOY))
                @logrosOffset -= 1
              end
              @sprites["slider"].y += @sliderStep
              if @lastDiagonalIndex != 0
                @sprites["selector"].x = getInitialPos(@indexSel % ICONOSPORFILA)[0] - 4
              end
              showTexts(@indexSel)
            end
          end

        # Selección hacia arriba, Input::UP cambia a la fila superior y Input::L cambia a la página anterior (salta tantas filas como indique NUMFILAS)
        elsif Input.trigger?(Input::UP) || Input.trigger?(Input::L)
          numsalto = 1
          numsalto = NUMFILAS if Input.trigger?(Input::L)
          numsalto.times do
            salto = ICONOSPORFILA
            if @lastDiagonalIndex != 0
              @descOffset = 0
              @indexSel = @lastDiagonalIndex
              @lastDiagonalIndex = 0
              @currentRow -= 1
              pos = getInitialPos(@indexSel % ICONOSPORFILA)
              @sprites["selector"].x = getInitialPos(@indexSel % ICONOSPORFILA)[0] - 4
              @sprites["selector"].y = getFilaY(@currentRow) - 4
              @sprites["slider"].y -= @sliderStep
              showTexts(@indexSel)
            elsif @indexSel - salto >= 0
              @logrosOffset = 0
              @indexSel -= salto
              if @currentRow - 1 >= 0
                @currentRow -= 1
                @sprites["selector"].y = getFilaY(@currentRow) - 4
              else
                moveLogros(ICONO_H + ESPACIADOY)
                @logrosOffset += 1
              end
              @sprites["slider"].y -= @sliderStep
              showTexts(@indexSel)
            end
          end

        # Selecciona el logro de la izquierda. Si está en la primera columna, cambia a la fila siguiente y selecciona el logro más a la derecha
        elsif Input.trigger?(Input::LEFT)
          if @indexSel - 1 >= 0
            @descOffset = 0
            @indexSel -= 1
            if @indexSel % ICONOSPORFILA == ICONOSPORFILA - 1
              if @currentRow - 1 >= 0
                @currentRow -= 1
                @lastDiagonalIndex = 0
                @sprites["selector"].y = getFilaY(@currentRow) - 4
              else
                moveLogros(ICONO_H + ESPACIADOY)
                @logrosOffset += 1
              end
              @sprites["slider"].y -= @sliderStep
            end
            @sprites["selector"].x = getInitialPos(@indexSel % ICONOSPORFILA)[0] - 4
            showTexts(@indexSel)
          end

        # Selecciona el logro de la derecha. Si está en la última columna, cambia a la fila anterior y selecciona el logro más a la izquierda
        elsif Input.trigger?(Input::RIGHT)
          if @indexSel + 1 <= @logros.size - 1
            @descOffset = 0
            @indexSel += 1
            if @indexSel % ICONOSPORFILA == 0
              if @currentRow + 1 < NUMFILAS
                @currentRow += 1
                @sprites["selector"].y = getFilaY(@currentRow) - 4
              else
                moveLogros(-(ICONO_H + ESPACIADOY))
                @logrosOffset -= 1
              end
              @sprites["slider"].y += @sliderStep
            end
            @sprites["selector"].x = getInitialPos(@indexSel % ICONOSPORFILA)[0] - 4
            showTexts(@indexSel)
          end

        # Con la tecla A del teclado se hace scroll al texto de la descripción si es posible
        elsif Input.trigger?(Input::X)
          # normtext = [word,x,y,textwidth,textheight,color]
          normtext = getLineBrokenChunks(@overlayDesc, @logros[@indexSel].desc, @overlayDesc.width,nil,true)
          hiddenlines=0
          lasty=0
          for i in 0...normtext.length
            # Esta letra está fuera de los límites en una nueva línea
            if @maxheight > 0 && normtext[i][2]>= @maxheight && lasty<normtext[i][2]
              hiddenlines+=1
            end
            lasty=normtext[i][2]
          end
          # Aplica el desplazamiento de la descripción
          hiddenlines += @descOffset
          # Si hay líneas ocultas, desplaza el texto
          if hiddenlines > 0
            @descOffset -= 1
            showTexts(@indexSel)
          # Si no hay líneas ocultas y el texto está desplazado, lo devuelve al principio
          elsif hiddenlines == 0 && @descOffset < 0
            @descOffset = 0
            showTexts(@indexSel)
          end
        end # if Input.trigger?(XXX)
      end # if @logros.size > 0
    end
    Input.update
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
  end

  # Pinta los textos del logro
  def showTexts(index)
    return if index < 0 || index > @logros.size
    logro = @logros[index]
    @overlay.clear
    textpos = [
        [logro.name,35,276,0,logro.status == LOGRO_COMPLETADO ? COLORCOMPLETADO : COLORBASE,COLORSOMBRA]
    ]
    pbDrawTextPositions(@overlay,textpos)
    @overlayDesc.clear
    drawTextEx(@overlayDesc,0,@descOffset*32+4,@overlayDesc.width,2-@descOffset,logro.desc,COLORBASE,COLORSOMBRA)
  end
end
