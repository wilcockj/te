function te.load()
  W, H = te.window.getDimensions()
end

function te.update(dt)
  -- ran each frame
end

function te.keypressed(key)
  if key == "escape" then
    te.event.quit(0)
  end
end

function te.draw()
  local fps = te.window.getFPS()

  te.graphics.setColor(GREEN, BLACK)
  te.graphics.print(string.format("FPS: %d", fps), 1, 1)

  te.graphics.setColor(WHITE, BLACK)
  local text = "TE TEMPLATE"
  te.graphics.print(text, W / 2 - (#text / 2) + 1, H / 2 + 1)
end
