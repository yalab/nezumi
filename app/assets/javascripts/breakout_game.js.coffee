SCREEN_WIDTH    = 680
SCREEN_HEIGHT   = 960
SCREEN_CENTER_X = SCREEN_WIDTH  / 2
SCREEN_CENTER_Y = SCREEN_HEIGHT / 2

BLOCK_COLS   = 8
BLOCK_ROWS   = 3
MARGIN       = 4
BLOCK_NUM    = BLOCK_COLS * BLOCK_ROWS
BLOCK_WIDTH  = SCREEN_WIDTH / BLOCK_COLS
BLOCK_HEIGHT = 30

BACKGROUND = "rgba(220, 220, 220, 1.0)"
rand = tm.util.Random.randint
MAP = tm.dom.Element("#world")
tm.main () ->
  app = tm.app.CanvasApp("#world")

  MAP.event.pointstart (e) ->
    MAP.eventStartPointX = e.pointX
    e.stop()
  MAP.event.pointmove (e) ->
    if MAP.eventStartPointX && (distance = MAP.eventStartPointX - e.pointX)
      app.keyboard.clearKeyPress()
      if distance > 0
        app.keyboard.keyPress("left")
      else if distance < 0
        app.keyboard.keyPress("right")
    e.stop()
  MAP.event.pointend (e) ->
    MAP.eventStartPointX = null
    app.keyboard.clearKeyPress()
    e.stop()

  app.resize(SCREEN_WIDTH, SCREEN_HEIGHT)
  app.fitWindow()
  app.background = BACKGROUND
  app.replaceScene(GameScene())
  app.run()

tm.define("GameScene",
  superClass: "tm.app.Scene"
  init: () ->
    @superInit()
    @blockGroup = tm.app.CanvasElement()
    @addChild(@blockGroup)
    @bullet = Bullet().addChildTo(@)
    @bar    = Bar().addChildTo(@)
    for rows in [0..BLOCK_ROWS-1]
      for cols in [0..BLOCK_COLS-1]
        block = Block(cols, rows).addChildTo(@blockGroup)
)

tm.define("Block",
  superClass: "tm.app.Shape",
  init: (cols, rows) ->
    @superInit(BLOCK_WIDTH - MARGIN, BLOCK_HEIGHT - MARGIN)
    @setBoundingType("rect")
    angle = rand(0, 360)
    @canvas.clearColor("hsl({0}, 80%, 70%)".format(angle))
    @x = (BLOCK_WIDTH / 2) + BLOCK_WIDTH * cols + MARGIN
    @y = (BLOCK_HEIGHT / 2) + BLOCK_HEIGHT * rows + MARGIN
)

tm.define("Bar",
  superClass: "tm.app.Shape",
  init: () ->
    @superInit(220, 20)
    @setBoundingType("rect")
    @canvas.clearColor("hsl({0}, 80%, 70%)".format(300))
    @x = SCREEN_CENTER_X
    @y = SCREEN_HEIGHT - 50
  update: (app) ->
    @x += 10 if app.keyboard.getKey("right") && (@x + @width / 2 != SCREEN_WIDTH)
    @x -= 10 if app.keyboard.getKey("left") && (@x + @width / 2 - @width != 0)
)

tm.define("Bullet",
  superClass: 'tm.app.CircleShape',
  init: () ->
    @superInit(20, 20)
    @y_speed = 15
    @x_speed = 5
    @canvas.clearColor(BACKGROUND)
    @x = 250
    @y = 600
    @renderCircle({strokeStyle: BACKGROUND, fillStyle: "hsl({0}, 80%, 70%)".format(255)})
  update: (app) ->
    @y += @y_speed
    @x += @x_speed
    if @y > SCREEN_HEIGHT
      app.replaceScene(GameOver(app.currentScene))
      return
    @x_bound() if @x > SCREEN_WIDTH || @x < 1
    @x_factor(app) if app.currentScene.bar && @isHitElementRect(app.currentScene.bar)
    for block in app.currentScene.blockGroup.children
      if block && @isHitElementRect(block)
        block.remove()
        @y_bound()
        break
    @y_bound() if @y < 1
  y_bound: () ->
    @y_speed = -@y_speed
  x_bound: () ->
    @x_speed = -@x_speed
  x_factor: (app) ->
    factor = if app.keyboard.getKey("right")
               +rand(3, 10)
             else if app.keyboard.getKey("left")
               -rand(3, 10)
             else
               rand(-2, 2)
    @y_bound()
    @x_speed += factor
)

tm.define("GameOver",
  superClass: "tm.app.Scene"
  init: () ->
    OFFSET = 60
    @superInit()
    banner = tm.app.Label("Game Over")
    banner.setFontSize(80)
          .setAlign("center")
          .setBaseline("middle")
          .setX(SCREEN_CENTER_X)
          .setY(SCREEN_CENTER_Y - OFFSET)
    @addChild(banner)
    restartButtton = tm.app.GlossyButton(200, 80, "black", "Restart").addChildTo(@)
      .setPosition(SCREEN_CENTER_X, SCREEN_CENTER_Y + 120)
      .onpointingstart = (e) ->
        e.app.replaceScene(GameScene())
  update: (app) ->
    if app.keyboard.getKey("enter")
      app.replaceScene(GameScene())
)
