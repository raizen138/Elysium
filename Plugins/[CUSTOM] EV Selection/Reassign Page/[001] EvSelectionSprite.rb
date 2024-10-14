#===============================================================================
#
#===============================================================================
class EVsSelectionSprite < Sprite
  attr_reader :preselected
  attr_reader :index
  
  def initialize(viewport = nil)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/UI/Summary/cursor_evs")
    @frame = 0
    @index = 0
    @updating = false
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def refresh
    w = @movesel.width
    h = @movesel.height
    self.x = 239
    self.y = 92 + (self.index * 43)
    self.bitmap = @movesel.bitmap
    self.src_rect.set(0, 0, w, h)
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end