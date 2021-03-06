local eventtap = require('hs.eventtap')
local hotkey = require('hs.hotkey')
local mouse = require('hs.mouse')
local screen = require('hs.screen')
local timer = require('hs.timer')
local statusMessage = require('status-message')

local eventType = eventtap.event.types

local hyper = {'alt', 'cmd', 'ctrl', 'shift'}
local canvas = nil

-- Define circle attributes that will highlight the mouse/cursor
local circle = function(color)
  mouseLocation = { 
    x = mouse.getRelativePosition().x,
    y = mouse.getRelativePosition().y
  }
  return {
    type = 'circle',
    action = 'strokeAndFill',
    center = { x = mouseLocation.x, y = mouseLocation.y },
    fillColor = { hex = color, alpha = 0.5 },
    radius = '0.01',
    strokeColor = { white = 1 },
    strokeWidth = 4.0,
  }
end

-- Mouse events to watch
local mouseEvents = {
 eventType.leftMouseDown,
 eventType.leftMouseUp,
 eventType.mouseMoved,
 eventType.leftMouseDragged,
}

-- Watch mouse movements and mouse clicks
local spotMouse = eventtap.new(mouseEvents, function(event)
  -- Left mouse down
  if event:getType() == 1 then
    canvas:removeElement(1)
    canvas:appendElements(circle('#ff0000')) 
  -- Left mouse up
  elseif event:getType() == 2 then
    canvas:removeElement(1)
    canvas:appendElements(circle('#000000'))
  -- Mouse moved
  elseif event:getType() == 5 then
    canvas:removeElement(1)
    canvas:appendElements(circle('#000000'))
  -- Left mouse down and dragged
  elseif event:getType() == 6 then
    canvas:removeElement(1)
    canvas:appendElements(circle('#ff0000'))
  end
end)

-- Enter modal with hyper-quote
local spotMode = hotkey.modal.new(hyper, 39)

-- Create new canvas and draw circle around mouse as soon as modal is activated
spotMode.entered = function()
  statusMessage.new('Spotting Mouse'):alert()
  local frame = screen.mainScreen():frame()
  canvas = hs.canvas.new({x = 0, y = 0, w = frame.w, h = frame.h }):show()
  canvas:appendElements(circle('#000000'))
  spotMouse:start()
end

-- Exit modal, stop watching events and delete canvas
spotMode:bind({}, 39, function()
  statusMessage.new('Stopped Spotting Mouse'):alert()
  spotMode:exit()
  spotMouse:stop()
  canvas:delete()
end)
