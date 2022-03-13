#Script creado por Painkiller97
NOMBRES_LOGRO=[
"Logro 1",
"Logro 2",
"Logro 3",
"Logro 4",
"Logro 5",
"Logro 6",
"Logro 7",
"Logro 8",
"Logro 9",
"Logro 10",
"Logro 11",
"Logro 12",
"Logro 13",
"Logro 14",
"Logro 15"
]

DESCRIPCIONES_LOGRO=[
"Este es el Logro 1",
"Este es el Logro 2",
"Este es el Logro 3",
"Este es el Logro 4",
"Este es el Logro 5",
"Este es el Logro 6",
"Este es el Logro 7",
"Este es el Logro 8",
"Este es el Logro 9",
"Este es el Logro 10",
"Este es el Logro 11",
"Este es el Logro 12",
"Este es el Logro 13",
"Este es el Logro 14",
"Este es el Logro 15"
]

class Logro
    attr_accessor :icono
    attr_accessor :nombre
    attr_accessor :desc
    attr_accessor :iconogrande
 
    def initialize(icono, nombre, desc, iconogrande, viewport)
        self.icono = Sprite.new(viewport)
        self.icono.bitmap=RPG::Cache.picture(icono)
        self.iconogrande = Sprite.new(viewport)
        self.iconogrande.bitmap=RPG::Cache.picture(iconogrande)
        self.iconogrande.x = 163
        self.iconogrande.y = 24
        self.nombre = nombre
        self.desc = desc
     end   
    
   
    def update()
        self.icono.update
        self.iconogrande.update
    end
end
 
class Pokemon_Achievements_Scene
  def pbStartScene
    @page=0
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Logros/background")
   
    @sprites["animacion"]=Sprite.new(@viewport)
    @sprites["animacion"].bitmap=RPG::Cache.picture("Logros/Cuadraditos")
    @sprites["animacion"].blend_type=1
   
    @sprites["animacion"].opacity=36
    @red=Color.new(255,0,0)
    @select = 0
   
    @space_logros = 20
    @offset = 20
   
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
   
    @logros = []
    @logros[0] = Logro.new("Logros/LogroMini/LogroMini1", "nombre", "desc", "Logros/LogroGrande/Logro1", @viewport)
    @logros[1] = Logro.new("Logros/LogroMini/LogroMini2", "nombre", "desc", "Logros/LogroGrande/Logro2", @viewport)
    @logros[2] = Logro.new("Logros/LogroMini/LogroMini3", "nombre", "desc", "Logros/LogroGrande/Logro3", @viewport)
    @logros[3] = Logro.new("Logros/LogroMini/LogroMini4", "nombre", "desc", "Logros/LogroGrande/Logro4", @viewport)
    @logros[4] = Logro.new("Logros/LogroMini/LogroMini5", "nombre", "desc", "Logros/LogroGrande/Logro5", @viewport)
    @logros[5] = Logro.new("Logros/LogroMini/LogroMini6", "nombre", "desc", "Logros/LogroGrande/Logro6", @viewport)
    @logros[6] = Logro.new("Logros/LogroMini/LogroMini7", "nombre", "desc", "Logros/LogroGrande/Logro7", @viewport)
    @logros[7] = Logro.new("Logros/LogroMini/LogroMini8", "nombre", "desc", "Logros/LogroGrande/Logro8", @viewport)
    @logros[8] = Logro.new("Logros/LogroMini/LogroMini9", "nombre", "desc", "Logros/LogroGrande/Logro9", @viewport)
    @logros[9] = Logro.new("Logros/LogroMini/LogroMini10", "nombre", "desc", "Logros/LogroGrande/Logro10", @viewport)
    @logros[10] = Logro.new("Logros/LogroMini/LogroMini11", "nombre", "desc", "Logros/LogroGrande/Logro11", @viewport)
    @logros[11] = Logro.new("Logros/LogroMini/LogroMini12", "nombre", "desc", "Logros/LogroGrande/Logro12", @viewport)
    @logros[12] = Logro.new("Logros/LogroMini/LogroMini13", "nombre", "desc", "Logros/LogroGrande/Logro13", @viewport)
    @logros[13] = Logro.new("Logros/LogroMini/LogroMini14", "nombre", "desc", "Logros/LogroGrande/Logro14", @viewport)
    @logros[14] = Logro.new("Logros/LogroMini/LogroMini15", "nombre", "desc", "Logros/LogroGrande/Logro15", @viewport)

        

    @sprites["selector"] = @uparrow=AnimatedSprite.create("Graphics/Pictures/uparrow",8,2,@viewport)
    @sprites["selector"].x = (@logros[0].icono.bitmap.width)/2 + @offset - @sprites["selector"].framewidth/2
    @sprites["selector"].y = Graphics.height/2 + 25
    @sprites["selector"].play
    
    #Cosas pagina2
    
    @sprites["TitleBox"]=IconSprite.new(0,0,@viewport)
    @sprites["TitleBox"].x = 152
    @sprites["TitleBox"].y = 245
    @sprites["TitleBox"].visible=false
    @sprites["TitleBox"].setBitmap("Graphics/Pictures/Logros/LogroGrande/TitleBox")
    
    @sprites["TextBox"]=IconSprite.new(0,0,@viewport)
    @sprites["TextBox"].x = 6
    @sprites["TextBox"].y = 299
    @sprites["TextBox"].visible=false
    @sprites["TextBox"].setBitmap("Graphics/Pictures/Logros/LogroGrande/DescriptionBox")
    
    @sprites["overlay2"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay2"].visible=false
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    @nombrelogro = NOMBRES_LOGRO
    @desclogro = DESCRIPCIONES_LOGRO
    pbText
    pbInput
  end
 
  def pbText
    overlay=@sprites["overlay"].bitmap
    pubid=sprintf("%05d",$Trainer.public_ID($Trainer.id))
    baseColor=Color.new(250,250,250)
    shadowColor=Color.new(60,60,60)
    #textPositions=[
     #  [_INTL("Prueba"),274,326,false,baseColor,shadowColor]
     # ]
    #pbDrawTextPositions(overlay,textPositions)  
  end
 
  def update
    if @page==0
     @logros[0].iconogrande.visible = false
     @logros[1].iconogrande.visible = false
     @logros[2].iconogrande.visible = false
     @logros[3].iconogrande.visible = false
     @logros[4].iconogrande.visible = false
     @logros[5].iconogrande.visible = false
     @logros[6].iconogrande.visible = false
     @logros[7].iconogrande.visible = false
     @logros[8].iconogrande.visible = false
     @logros[9].iconogrande.visible = false
     @logros[10].iconogrande.visible = false
     @logros[11].iconogrande.visible = false
     @logros[12].iconogrande.visible = false
     @logros[13].iconogrande.visible = false
     @logros[14].iconogrande.visible = false
  
    end 
      @logros[@select].iconogrande.x = 163
      @logros[@select].iconogrande.y = 24
    
      @logros[@select].update
    iconscreen = 3
    nicon = 0
    for logro in @logros
        if @select >= iconscreen
          @offset2 = (@select-iconscreen) * (90 + @space_logros)
        else
          @offset2 = 0
        end 
        logro.icono.x = (logro.icono.bitmap.width + @space_logros) * nicon + @offset - @offset2
        logro.icono.y = Graphics.height/2 - logro.icono.bitmap.height / 2
    @sprites["selector"].x = ((@logros[0].icono.bitmap.width + @space_logros) * @select )+ (@logros[0].icono.bitmap.width)/2 + @offset - @offset2 - @sprites["selector"].framewidth/2
        logro.update
        nicon += 1
      end
    #Aqui se define si un logro esta conseguido o no, uso interruptores reservados
    #asi que cambialos de acuerdo a tu juego  
    if $game_variables[50]>=14 #Aqui se define el logro de platino al obtener todos
    @logros[0].icono.opacity = 255
    else  
    @logros[0].icono.opacity = 50
    end  
    
    if $game_switches[101] 
    @logros[1].icono.opacity = 255
    else  
    @logros[1].icono.opacity = 50
    end
  
    if $game_switches[102] 
    @logros[2].icono.opacity = 255
    else  
    @logros[2].icono.opacity = 50
    end  
  
    if $game_switches[103] 
    @logros[3].icono.opacity = 255
    else  
    @logros[3].icono.opacity = 50
    end  
    if $game_switches[104] 
    @logros[4].icono.opacity = 255
    else  
    @logros[4].icono.opacity = 50
  end  
  
  if $game_switches[105] 
    @logros[5].icono.opacity = 255
    else  
    @logros[5].icono.opacity = 50
  end  
  
  if $game_switches[106] 
    @logros[6].icono.opacity = 255
    else  
    @logros[6].icono.opacity = 50
  end  
  
  if $game_switches[107] 
    @logros[7].icono.opacity = 255
    else  
    @logros[7].icono.opacity = 50
  end  
  
  if $game_switches[108] 
    @logros[8].icono.opacity = 255
    else  
    @logros[8].icono.opacity = 50
  end  
  
  if $game_switches[109] 
    @logros[9].icono.opacity = 255
    else  
    @logros[9].icono.opacity = 50
  end  
  
  if $game_switches[110] 
    @logros[10].icono.opacity = 255
    else  
    @logros[10].icono.opacity = 50
  end  
  
  if $game_switches[111] 
    @logros[11].icono.opacity = 255
    else  
    @logros[11].icono.opacity = 50
  end  
  
  if $game_switches[112] 
    @logros[12].icono.opacity = 255
    else  
    @logros[12].icono.opacity = 50
  end  
  
  if $game_switches[113] 
    @logros[13].icono.opacity = 255
    else  
    @logros[13].icono.opacity = 50
  end  
  
  if $game_switches[114] 
    @logros[14].icono.opacity = 255
    else  
    @logros[14].icono.opacity = 50
    end  
  
  
  
    pbUpdateSpriteHash(@sprites)
    if @sprites["animacion"]
       @sprites["animacion"].x-=1
       @sprites["animacion"].x=0 if @sprites["animacion"].x==-64
       @sprites["animacion"].y-=1
       @sprites["animacion"].y=0 if @sprites["animacion"].y==-64
    end
    Input.update
  end  
  
  def textoLogro
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    overlay=@sprites["overlay2"].bitmap
    overlay.clear 
    baseColor=Color.new(225,225,225)
    shadowColor=Color.new(120,120,120)
    drawTextEx(overlay,157,250,320,0,@nombrelogro[@select],baseColor,shadowColor)
    drawTextEx(overlay,12,305,320,0,@desclogro[@select],baseColor,shadowColor)
    # textPositions=[
    #[_INTL,(@nombrelogro[@select]),157,250,0,baseColor,shadowColor],
    #[_INTL("{1} Descripcion ",@desclogro[@select]),12,305,0,baseColor,shadowColor]
    #]
    #drawTextEx(overlay,157,250,360,0,@nombrelogro[@select],baseColor,shadowColor) 
   #pbDrawTextPositions(overlay,textPositions)
  end  
 
  def pbInput
    if @page==0
      if Input.trigger?(Input::RIGHT) && !(@select==@logros.length - 1)
          @select+=1; pbSEPlay("Select")
      end    
      if Input.trigger?(Input::LEFT) && !(@select==0)
          @select-=1; pbSEPlay("Select")
        end
      end  
    if Input.trigger?(Input::C) 
      pbSEPlay("Select")
      switchPage
      textoLogro
    end
  end  
 
  def pbLogros
    loop do
      Graphics.update
      Input.update
      self.pbInput
      self.update
      if Input.trigger?(Input::B)
       pbSEPlay("expfull")
        break
      end
    end
  end
  
  def switchPage
    if @page==1
      firstPage
    else
      secondPage
      textoLogro
    end
  end  
  
  def firstPage
    @page=0
    
    @sprites["overlay"].visible=true
    for logro in @logros
      logro.icono.visible=true
    end  
    if $game_switches[184]
    @logros[0].icono.opacity = 255
    else  
    @logros[0].icono.opacity = 100
    end  
    
    @sprites["selector"].visible=true
    @sprites["overlay"].visible=true
    @sprites["TitleBox"].visible=false
    @sprites["TextBox"].visible=false
 
    @sprites["overlay2"].visible=false
@logros[0].iconogrande.visible = false
     @logros[1].iconogrande.visible = false
     @logros[2].iconogrande.visible = false
     @logros[3].iconogrande.visible = false
     @logros[4].iconogrande.visible = false
     @logros[5].iconogrande.visible = false
     @logros[6].iconogrande.visible = false
     @logros[7].iconogrande.visible = false
     @logros[8].iconogrande.visible = false
     @logros[9].iconogrande.visible = false
     @logros[10].iconogrande.visible = false
     @logros[11].iconogrande.visible = false
     @logros[12].iconogrande.visible = false
     @logros[13].iconogrande.visible = false
     @logros[14].iconogrande.visible = false
  end
  
  def secondPage
    @page=1
    @sprites["overlay"].visible=false
    for logro in @logros
      logro.icono.visible=false
    end
    
    @sprites["selector"].visible=false
    @sprites["overlay"].visible=false
    @sprites["TitleBox"].visible=true
    @sprites["TextBox"].visible=true
    @sprites["overlay2"].visible=true
    @logros[@select].iconogrande.visible = true
    #Aqui se define si un logro esta conseguido o no, uso interruptores reservados
    #asi que cambialos de acuerdo a tu juego
    if $game_variables[50]>=14 #Aqui se define el logro de platino al obtener todos
    @logros[0].iconogrande.opacity = 255
    else  
    @logros[0].iconogrande.opacity = 50
  end  
  
  if $game_switches[101] 
    @logros[1].iconogrande.opacity = 255
    else  
    @logros[1].iconogrande.opacity = 50
    end
  
    if $game_switches[102] 
    @logros[2].iconogrande.opacity = 255
    else  
    @logros[2].iconogrande.opacity = 50
    end  
  
    if $game_switches[103] 
    @logros[3].iconogrande.opacity = 255
    else  
    @logros[3].iconogrande.opacity = 50
    end  
    if $game_switches[104] 
    @logros[4].iconogrande.opacity = 255
    else  
    @logros[4].iconogrande.opacity = 50
  end  
  
  if $game_switches[105] 
    @logros[5].iconogrande.opacity = 255
    else  
    @logros[5].iconogrande.opacity = 50
  end  
  
  if $game_switches[106] 
    @logros[6].iconogrande.opacity = 255
    else  
    @logros[6].iconogrande.opacity = 50
  end  
  
  if $game_switches[107] 
    @logros[7].iconogrande.opacity = 255
    else  
    @logros[7].iconogrande.opacity = 50
  end  
  
  if $game_switches[108] 
    @logros[8].iconogrande.opacity = 255
    else  
    @logros[8].iconogrande.opacity = 50
  end  
  
  if $game_switches[109] 
    @logros[9].iconogrande.opacity = 255
    else  
    @logros[9].iconogrande.opacity = 50
  end  
  
  if $game_switches[110] 
    @logros[10].iconogrande.opacity = 255
    else  
    @logros[10].iconogrande.opacity = 50
  end  
  
  if $game_switches[111] 
    @logros[11].iconogrande.opacity = 255
    else  
    @logros[11].iconogrande.opacity = 50
  end  
  
  if $game_switches[112] 
    @logros[12].iconogrande.opacity = 255
    else  
    @logros[12].iconogrande.opacity = 50
  end  
  
  if $game_switches[113] 
    @logros[13].iconogrande.opacity = 255
    else  
    @logros[13].iconogrande.opacity = 50
  end  
  
  if $game_switches[114] 
    @logros[14].iconogrande.opacity = 255
    else  
    @logros[14].iconogrande.opacity = 50
    end  
    
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
 

def pbCallAchievements
  scene=Pokemon_Achievements_Scene.new
  screen=Pokemon_Achievements.new(scene)
  screen.pbStartScreen
end
 
class Pokemon_Achievements
  def initialize(scene)
    @scene=scene
  end
 
  def pbStartScreen
    @scene.pbStartScene
    @scene.pbLogros
    @scene.pbEndScene
  end
end
