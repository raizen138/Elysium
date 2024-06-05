########## AUTORES: Kyu y Clara ☆ ################################################
# Abrir el gacha: openGacha
# Dar monedas al jugador: $PokemonGlobal.gachaCoins += cantidad
##################################################################################
# Gacha Config
##################################################################################
CONFIG_URL = "https://gachapgd.000webhostapp.com/gacha/config.txt"

TIERCOLORS = [Color.new(255,255,255),Color.new(112,112,112),Color.new(209,162,148),
              Color.new(229,229,229),Color.new(255,197,41),Color.new(62, 135, 211),Color.new(221, 28, 71)]
TIERSOUNDS = ["ItemGet.ogg","ItemGet.ogg","ItemGet.ogg","ItemGet.ogg","ItemGet.ogg","ItemGet.ogg","ItemGet.ogg"]

FRASES = ["Aprovecha que no tienes dinero y huye de este juego infernal. No merece la pena",
          "Vaya, no tienes monedas... pity! that´s bad",
          "Ante una mala racha, no te gastes dinero en un gacha",
          "No tendrás dinero, pero te ha tocado un mensaje de 5 estrellas. ¿Yay?",
          "Probabilidad condicional es la probabilidad de que ocurra un evento A, sabiendo que también sucede otro evento B. La probabilidad condicional se escribe P(A|B) o P(A/B), y se lee «la probabilidad de A dado B».\nNo tiene por qué haber una relación causal o temporal entre A y B. A puede preceder en el tiempo a B, sucederlo o pueden ocurrir simultáneamente. A puede causar B, viceversa o pueden no tener relación causal. Las relaciones causales o temporales son nociones que no pertenecen al ámbito de la probabilidad. Pueden desempeñar un papel o no, dependiendo de la interpretación que se le dé a los eventos.\nEn otras palabras: Sigue tirando." 
          ]

#BannerReward###################################################################
class BannerReward < Sprite
  def initialize(id,reward,stars,viewport=nil)
    super(viewport)
    @viewport = viewport
    @id = id
    @stars = stars - 1
    @reward = reward
    @color = TIERCOLORS[stars-1]
    
    self.bitmap = Bitmap.new(160,160)
    @light = Sprite.new(@viewport)
    @light.bitmap = Bitmap.new("Graphics/Pictures/Gacha/gacha")
    @light.ox = @light.bitmap.width/2
    @light.oy = @light.bitmap.height/2
    #@light.x = Graphics.width/2
    #@light.y = Graphics.height/2
    @light.zoom_x = 0.5
    @light.zoom_y = 0.5
    #@light.opacity = 0
    @light.color = TIERCOLORS[@stars]
    @light.angle += 2

    @rewardSprite = Sprite.new(@viewport)
    @rewardSprite.bitmap = Bitmap.new(@reward)
    @rewardSprite.ox = @rewardSprite.bitmap.width/2 
    @rewardSprite.oy = @rewardSprite.bitmap.height/2 
    if @rewardSprite.bitmap.width <= 100 && @rewardSprite.bitmap.height <= 100
      @rewardSprite.zoom_x = 2.0
      @rewardSprite.zoom_y = 2.0
    end
    
    @starsSprite = Sprite.new(@viewport)
    starsBitmap = Bitmap.new("Graphics/Pictures/Gacha/Estrellas")
    @starsSprite.bitmap = Bitmap.new(starsBitmap.width, starsBitmap.height/7)
    starsY = @starsSprite.bitmap.height*@stars
    starsRect = Rect.new(0, starsY, @starsSprite.bitmap.width, @starsSprite.bitmap.height)
    @starsSprite.bitmap.blt(0, 0, starsBitmap, starsRect)
    @starsSprite.x= 36
    @starsSprite.y = 140
    @starsSprite.ox = @starsSprite.bitmap.width/2 
    @starsSprite.oy = @starsSprite.bitmap.height/2 
  end


  def x=(value)
    super(value)
    @rewardSprite.x = value + self.bitmap.width/2 - self.ox
    @starsSprite.x = value + 36 + @starsSprite.ox - self.ox
    @light.x = value + self.bitmap.width/2 - self.ox
  end
  
  def y=(value)
    super(value)
    @rewardSprite.y = value + self.bitmap.height/2 - self.oy
    y = 140
    @starsSprite.y = value + y + @starsSprite.oy - self.oy
    @light.y = value + self.bitmap.height/2 - self.oy
  end
  
  def zoom_x=(value)
    super(value)
    @rewardSprite.zoom_x = value + 1.0
    @starsSprite.zoom_x = value
    @light.zoom_x = value
  end
  
  def zoom_y=(value)
    super(value)
    @rewardSprite.zoom_y = value + 1.0
    @starsSprite.zoom_y = value
    @light.zoom_y = value
  end
    
  def opacity=(value)
    super(value)
    @rewardSprite.opacity = value
    @starsSprite.opacity = value
    @light.opacity = value
  end
  
  def dispose
    @rewardSprite.dispose
    @starsSprite.dispose
    @light.dispose
  end
end

#BANNER#########################################################################

class BannerSprite < Sprite
  def initialize(bg,rewards,stars,viewport=nil)
    super(viewport)
    @viewport = viewport
    @bg = bg
    @rewards = rewards
    @stars = stars
    createGraphics
  end

  def createGraphics
    @bgSprite = Sprite.new(@viewport)
    @bgSprite.bitmap = Bitmap.new(@bg)
    @bgSprite.ox = @bgSprite.bitmap.width/2
    @bgSprite.oy = @bgSprite.bitmap.height/2
    @bgSprite.x = Graphics.width/2
    @bgSprite.y = Graphics.height/2
    
    @reward1 = BannerReward.new(0,@rewards[0],@stars[0],@viewport)
    @reward1.x = 16
    @reward1.y = 111
    
    @reward2 = BannerReward.new(1,@rewards[1],@stars[1],@viewport)
    @reward2.x = 176
    @reward2.y = 111
    
    @reward3 = BannerReward.new(2,@rewards[2],@stars[2],@viewport)
    @reward3.x = 336
    @reward3.y = 111
  end
  
  def x=(value)
    super(value)
    @bgSprite.x = value + @bgSprite.bitmap.width/2
    @reward1.x = value + 16
    @reward2.x = value + 176
    @reward3.x = value + 336
  end
  
  def dispose
    @bgSprite.dispose
    @reward1.dispose
    @reward2.dispose
    @reward3.dispose
    super
  end
end

#INTERFAZ#######################################################################

class GachaScene
  def initialize(banners)
    $PokemonGlobal.gachaCoins ||= 0 if !$PokemonGlobal.gachaCoins
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sel = 1
    @banners = banners
    @banner_sel = 0
    
    for i in 0...@banners.length
      @sprites["banner#{i}"] = BannerSprite.new(@banners[i].bg, @banners[i].rewards, @banners[i].stars, @viewport)
      @sprites["banner#{i}"].x = Graphics.width*i
    end
    
    @sprites["leftArrow"] = Sprite.new(@viewport)
    @sprites["leftArrow"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/leftArrow")
    @sprites["leftArrow"].ox = @sprites["leftArrow"].bitmap.width/2
    @sprites["leftArrow"].oy = @sprites["leftArrow"].bitmap.height/2
    @sprites["leftArrow"].x = 20
    @sprites["leftArrow"].y = Graphics.height/2
    
    @sprites["rightArrow"] = Sprite.new(@viewport)
    @sprites["rightArrow"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/rightArrow")
    @sprites["rightArrow"].ox = @sprites["rightArrow"].bitmap.width/2
    @sprites["rightArrow"].oy = @sprites["rightArrow"].bitmap.height/2
    @sprites["rightArrow"].x = Graphics.width - 20
    @sprites["rightArrow"].y = Graphics.height/2
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Fondo")
    
    @sprites["bannerSel"] = Sprite.new(@viewport)
    @sprites["bannerSel"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/sel_shine")
    @sprites["bannerSel"].y = 248
    @sprites["bannerSel"].visible = false
    
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width,96)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["text"].bitmap.font.size = 45
    
    @sprites["button1"] = Sprite.new(@viewport)
    @sprites["button2"] = Sprite.new(@viewport)
    @sprites["button3"] = Sprite.new(@viewport)
    
    @sprites["coinsIcon"] = Sprite.new(@viewport)
    @sprites["coinsIcon"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/coin")
    @sprites["coinsIcon"].x = 10
    @sprites["coinsIcon"].y = 110
    
    @sprites["coins"] = Sprite.new(@viewport)
    @sprites["coins"].bitmap = Bitmap.new(Graphics.width,25)
    @sprites["coins"].x = 30
    @sprites["coins"].y = 100
    pbSetSystemFont(@sprites["coins"].bitmap)
    refresh
    update
  end
  
  def refresh
    base   = Color.new(248,248,248)
    shadow = Color.new(72,80,88)
    
    if @sel == 0
      @sprites["button1"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton Chiquito Sel")
    else
      @sprites["button1"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton Chiquito")
    end
    @sprites["button1"].x = 16
    @sprites["button1"].y = 336
    pbSetSystemFont(@sprites["button1"].bitmap)
    pbDrawShadowText(@sprites["button1"].bitmap,0,6,128,32,"Información",base,shadow,1)
    
    if @sel == 1
      @sprites["button2"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton Sel")
    else
      @sprites["button2"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton")
    end
    @sprites["button2"].x = 192
    @sprites["button2"].y = 304
    @sprites["button2"].bitmap.font.size = 38
    pbSetSystemFont(@sprites["button2"].bitmap)
    pbDrawShadowText(@sprites["button2"].bitmap,9,13,112,58,"Tirar",base,shadow,1)

    if @sel == 2
      @sprites["button3"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton Chiquito Sel")
    else
      @sprites["button3"].bitmap = Bitmap.new("Graphics/Pictures/Gacha/Boton Chiquito")
    end
    @sprites["button3"].x = 368
    @sprites["button3"].y = 336
    pbSetSystemFont(@sprites["button3"].bitmap)
    pbDrawShadowText(@sprites["button3"].bitmap,0,6,128,32,"Salir",base,shadow,1)
    
    if @sel == 3
      @sprites["bannerSel"].visible = true
    else
      @sprites["bannerSel"].visible = false
    end
    
    if @banner_sel == 0
      @sprites["leftArrow"].opacity = 100
    else
      @sprites["leftArrow"].opacity = 255
    end
    
    if @banner_sel == @banners.length-1
      @sprites["rightArrow"].opacity = 100
    else
      @sprites["rightArrow"].opacity = 255
    end
    
    @sprites["text"].bitmap.clear
    pbDrawShadowText(@sprites["text"].bitmap,0,25,Graphics.width,98,@banners[@banner_sel].name,base,shadow,1)
    
    @sprites["coins"].bitmap.clear
    pbDrawShadowText(@sprites["coins"].bitmap,0,5,Graphics.width,25,"x"+$PokemonGlobal.gachaCoins.to_s,base,shadow)
  end
  
  def changeBanner(dir)
    if dir == 0 && @banner_sel != @banners.length-1
      move = Graphics.width/14.0
      14.times do
        for i in 0...@banners.length
          @sprites["banner#{i}"].x -= move
        end
        pbWait(1)
      end
      @banner_sel += 1
    elsif dir == 1 && @banner_sel != 0
      move = Graphics.width/14.0
      14.times do
        for i in 0...@banners.length
          @sprites["banner#{i}"].x += move
        end
        pbWait(1)
      end
      @banner_sel -= 1
    end
  end
  
  def summaryWindow(width, interpad)
    window = SpriteWindow_Base.new(37,27,width,330)
    window.z = 99999
    window.windowskin = Bitmap.new("Graphics/windowskins/goldskin")
    text = @banners[@banner_sel].description
    totalheight = 0
    
    isDarkSkin=isDarkWindowskin(window.windowskin)
    colortag=""
    if ($game_message && $game_message.background>0) ||
       ($game_system && $game_system.respond_to?("message_frame") &&
        $game_system.message_frame != 0)
      colortag=getSkinColor(window.windowskin,0,true)
    else
      colortag=getSkinColor(window.windowskin,0,isDarkSkin)
    end
    text = colortag + text
    
    #window.newWithSize(text,37,27,width,330)
    aux = getGachaLineChunks(text, width-37,colortag)
    canvas = Bitmap.new(439,(32 + interpad)*(aux.length))
    pbSetSystemFont(canvas)
    
    for i in 0...aux.length
      chr = getFormattedText(canvas,0,totalheight,canvas.width-37, Graphics.height, aux[i])
      drawFormattedChars(canvas,chr)
      totalheight += 32 + interpad
    end
    window.contents = canvas
    
    loop do
      if Input.press?(Input::UP) && window.oy != 0
        window.oy -= 10
      end
      if Input.press?(Input::DOWN) && window.oy < canvas.height - 200
        window.oy += 10
      end
      if Input.trigger?(Input::B)
        window.dispose
        Input.update
        break
      end
      Graphics.update
      Input.update
    end
  end
      
  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Graphics.update
    Input.update
  end
  
  def rewardAnim(filename,stars,qty) #Animación para obtener premios
    color = TIERCOLORS[stars-1]
    sound = TIERSOUNDS[stars-1]
    base   = Color.new(248,248,248)
    shadow = Color.new(72,80,88)
    
    bg = Sprite.new(@viewport)
    bg.bitmap = Bitmap.new("Graphics/Pictures/Gacha/rewardBG")
    bg.tone = Tone.new(color.red, color.green, color.blue)
    
    # light = Sprite.new(@viewport)
    # light.bitmap = Bitmap.new("Graphics/Pictures/Gacha/gacha")
    # light.ox = light.bitmap.width/2
    # light.oy = light.bitmap.height/2
    # light.x = Graphics.width/2
    # light.y = Graphics.height/2
    # #light.zoom_x = 11.0
    # #light.zoom_y = 11.0
    # light.opacity = 0
    # light.color = color
    
    reward = BannerReward.new(0,filename,stars,@viewport)
    reward.ox = reward.bitmap.width/2
    reward.oy = reward.bitmap.height/2
    reward.x = Graphics.width/2
    reward.y = Graphics.height/2
    reward.opacity=0
    reward.zoom_x = 11.0
    reward.zoom_y = 11.0

    qtyIcon = Sprite.new(@viewport)
    qtyIcon.bitmap = Bitmap.new(Graphics.width,25)
    qtyIcon.x = Graphics.width/2 + 20
    qtyIcon.y = Graphics.height/2 + 15
    qtyIcon.opacity=0
    pbSetSystemFont(qtyIcon.bitmap)
    qtyIcon.bitmap.clear
    pbDrawShadowText(qtyIcon.bitmap,0,5,Graphics.width,25,"x"+qty.to_s,base,shadow)
    
    pbSEPlay(sound)
    frame = 0
    while (!Input.trigger?(Input::C) && frame >= 9) || frame <= 9
      if (0..9).include?(frame)
        #light.opacity += 25.5
        #light.zoom_x -= 1.0
        #light.zoom_y -= 1.0
        #if qty > 1
        #  qtyIcon.opacity += 25.5
        #end
        qtyIcon.opacity += 25.5
        reward.opacity += 25.5
        reward.zoom_x -= 1.0
        reward.zoom_y -= 1.0
      end
      #light.angle += 2
      frame+=1
      Graphics.update
      Input.update
    end
    pbSEStop()
    
    bg.dispose
    reward.dispose
    qtyIcon.dispose
    #light.dispose
  end
  
  def pokeReward(poke,stars) # Obtención de pokémon
    #file = pbCheckPokemonBitmapFiles([poke.species, false, poke.isFemale?,poke.isShiny?, poke.form]) 
    file = GameData::Species.front_sprite_filename(poke.species, poke.form, 0, poke.shiny?)
    rewardAnim(file,stars,0)
    poke.obtain_method = 2
    poke.obtain_text = "Gachapon"
    pbAddPokemonSilent(poke)
    Game.save
  end
  
  def itemReward(item,stars,qty) # Obtención de objetos
    #file = pbItemIconFile(getID(PBItems,item))
    file = GameData::Item.icon_filename(item)
    rewardAnim(file,stars,qty)
    $bag.add(item,qty)
    Game.save
  end

  def update 
    loop do
      if Input.trigger?(Input::RIGHT)
        if @sel == 3
          changeBanner(0)
        elsif @sel != 2
          @sel+=1
        end
        refresh
      end
      
      if Input.trigger?(Input::LEFT)
        if @sel == 3
          changeBanner(1)
        elsif @sel != 0
          @sel -= 1
        end
        refresh
      end
      
      if Input.trigger?(Input::L)
        changeBanner(1)
        refresh
      end
      
      if Input.trigger?(Input::R)
        changeBanner(0)
        refresh
      end
      
      if Input.trigger?(Input::UP) && @sel != 3
        @sel = 3
        refresh
      end
      
      if Input.trigger?(Input::DOWN) && @sel != 1
        @sel = 1
        refresh
      end
      
      if Input.trigger?(Input::C) 
        case @sel
        when 0 #Información
          summaryWindow(439,5)
        when 1 #Tirar
          if $PokemonGlobal.gachaCoins != 0 
            if Kernel.pbMessage("¿Quieres hacer una tirada? SE GUARDARÁ LA PARTIDA",["Sí","No"])==0
              gachaponRead(@banners[@banner_sel].script)
              $PokemonGlobal.gachaCoins -= 1
              if Game.save
                pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game] The previous save file has been backed up.\\wtnp[30]"))
              else
                pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
              end
              refresh
            end
          else
             Kernel.pbMessage(FRASES[rand(FRASES.length)])
          end
        when 2 #Salir
          dispose
          break
        end       
      end
      
      if Input.trigger?(Input::B)
        dispose
        break
      end
      
      Graphics.update
      Input.update
    end
  end
end