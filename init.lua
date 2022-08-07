-- HANDLE SCROLLING
local deferred = false
local rightDown = false

doKeyStroke = function(modifiers, character)
    local event = require("hs.eventtap").event
    event.newKeyEvent(modifiers, string.lower(character), true):post()
    event.newKeyEvent(modifiers, string.lower(character), false):post()
end

overrideRightMouseDown = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDown }, function(e)
  -- print("down")
  deferred = true
  rightDown = true
  return true
end):start()


overrideRightMouseUp = hs.eventtap.new({ hs.eventtap.event.types.rightMouseUp }, function(e)
  -- print("up")

  if(rightDown) then
    rightDown = false
  end

  if (deferred) then
    overrideRightMouseDown:stop()
    overrideRightMouseUp:stop()
    hs.eventtap.rightClick(e:location())
    overrideRightMouseDown:start()
    overrideRightMouseUp:start()
    return true
  end
  return false
end):start()

local oldmousepos = {}
local scrollmult = -4   -- negative multiplier makes mouse work like traditional scrollwheel

dragRightToScroll = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDragged }, function(e)
  deferred = false
  oldmousepos = hs.mouse.absolutePosition()    
  local dx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
  local dy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])
  local scroll = hs.eventtap.event.newScrollEvent({-dx * scrollmult, -dy * scrollmult},{},'pixel')
  -- put the mouse back
  hs.mouse.absolutePosition(oldmousepos)
  return true, {scroll}
end):start()

-- 右クリック＋スクロールで戻る/進む
scrollRightToNavigate = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(e)
  deferred = false
  if (rightDown) then
    -- local wheel_x = e:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2)
    local wheel_y = e:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)
    -- スクロールアップで戻る、スクロールダウンで進む
    if wheel_y > 0 then
      doKeyStroke({'cmd'}, ']')
    elseif wheel_y < 0 then
      doKeyStroke({'cmd'}, '[')
    end
    return true, {wheel_y}
  end
end):start()
