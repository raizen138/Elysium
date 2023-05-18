class MiningGameScene
def pbMain
    pbSEPlay("Mining ping")
    pbMessage(_INTL("Something pinged in the wall!\n{1} confirmed!", @items.length))
    loop do
      update
      Graphics.update
      Input.update
      next if @sprites["cursor"].isAnimating?
      # Check end conditions
      if @sprites["crack"].hits >= 49
        @sprites["cursor"].visible = false
        pbSEPlay("Mining collapse")
        collapseviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        collapseviewport.z = 99999
        @sprites["collapse"] = BitmapSprite.new(Graphics.width, Graphics.height, collapseviewport)
        collapseTime = Graphics.frame_rate * 8 / 10
        collapseFraction = (Graphics.height.to_f / collapseTime).ceil
        (1..collapseTime).each do |i|
          @sprites["collapse"].bitmap.fill_rect(0, collapseFraction * (i - 1),
                                                Graphics.width, collapseFraction * i, Color.new(0, 0, 0))
          Graphics.update
        end
        pbMessage(_INTL("The wall collapsed!"))
        break
      end
      foundall = true
      @items.each do |i|
        foundall = false if !i[3]
        break if !foundall
      end
      if foundall
        @sprites["cursor"].visible = false
        pbWait(Graphics.frame_rate * 3 / 4)
        pbSEPlay("Mining found all")
        pbMessage(_INTL("Everything was dug up!"))
        break
      end
      # Input
      #mousetech
      if System.mouse_in_window
        if Input.mouse_x.between?(0,BOARD_WIDTH*32) && Input.mouse_y.between?(64,64+BOARD_HEIGHT*32) #Mouse is on board
          x = Input.mouse_x/32
          y = (Input.mouse_y-64)/32
          newpos = x + y*BOARD_WIDTH
          @sprites["cursor"].position = newpos
          pbHit if Input.trigger?(Input::MOUSELEFT)
        elsif Input.mouse_x.between?(428,508) #mouse is by tool icons
          if Input.mouse_y.between?(98,216) #mouse is by hammer
            if Input.trigger?(Input::MOUSELEFT)
              pbSEPlay("Mining tool change")
              newmode = 1
              @sprites["cursor"].mode = newmode
              @sprites["tool"].src_rect.set(newmode * 68, 0, 68, 100)
              @sprites["tool"].y = 254 - (144 * newmode)
            end
          elsif Input.mouse_y.between?(242,360) #mouse is by pick
            if Input.trigger?(Input::MOUSELEFT)
              pbSEPlay("Mining tool change")
              newmode = 0
              @sprites["cursor"].mode = newmode
              @sprites["tool"].src_rect.set(newmode * 68, 0, 68, 100)
              @sprites["tool"].y = 254 - (144 * newmode)
            end
          end
        end
      elsif Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
        if @sprites["cursor"].position >= BOARD_WIDTH
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position -= BOARD_WIDTH
        end
      elsif Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
        if @sprites["cursor"].position < (BOARD_WIDTH * (BOARD_HEIGHT - 1))
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position += BOARD_WIDTH
        end
      elsif Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
        if @sprites["cursor"].position % BOARD_WIDTH > 0
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position -= 1
        end
      elsif Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
        if @sprites["cursor"].position % BOARD_WIDTH < (BOARD_WIDTH - 1)
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position += 1
        end
      elsif Input.trigger?(Input::ACTION)   # Change tool mode
        pbSEPlay("Mining tool change")
        newmode = (@sprites["cursor"].mode + 1) % 2
        @sprites["cursor"].mode = newmode
        @sprites["tool"].src_rect.set(newmode * 68, 0, 68, 100)
        @sprites["tool"].y = 254 - (144 * newmode)
      elsif Input.trigger?(Input::USE)   # Hit
        pbHit
      elsif Input.trigger?(Input::BACK)   # Quit
        break if pbConfirmMessage(_INTL("Are you sure you want to give up?"))
      end
    end
    pbGiveItems
  end
  
end