function notify(msg)
   hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
end

squareDrawing = nil

function deleteSquarePointer()
   squareDrawing:delete()
   squareDrawing = nil
end

function drawSquarePointer()
   if squareDrawing then
      deleteSquarePointer()
   end

   -- Get the current co-ordinates of the mouse pointer
   mousepoint = hs.mouse.getAbsolutePosition()
   -- Prepare a big red circle around the mouse pointer
   squareDrawing = hs.drawing.rectangle(hs.geometry.rect(mousepoint.x-10, mousepoint.y-10, 20, 20))
   squareDrawing:setStrokeColor({["red"]=0.478431,["green"]=0.780392,["blue"]=0.960784,["alpha"]=1})
   squareDrawing:setFill(false)
   squareDrawing:setStrokeWidth(5)
   squareDrawing:show()
end

function reloadConfig()
   hs.reload()
   notify("Configuration was reloaded")
   keymapselect:exit()
end

function showWindows()
   s = ""
   for i = 0, 9 do
      if windows[i] ~= nil then
         s = s .. tostring(i) .. " - " .. windows[i]:title() .. "\n"
      end
   end
   notify(s)
   keymapselect:exit()
end

function rebind(n)
   window = hs.window.focusedWindow()
   windows[n] = window
   notify("Bound " .. window:title() .. " to " .. n)
   keymaprebind:exit()
end

function selectwin(w)
   prevwindow = hs.window.focusedWindow()
   w:focus()
end

function selectWinNumber(n)
   if windows[n] == nil then
      notify(tostring(n) .. " is not bound")
   else
      selectwin(windows[n])
   end
   keymapselect:exit()
end

function other()
   if prevwindow == nil then
      notify("No prev window")
   else
      selectwin(prevwindow)
   end
   keymapselect:exit()
end

function literal()
   -- exit first, otherwise the keyStroke is caught by the keymap again
   keymapselect:exit()
   hs.eventtap.keyStroke({}, "t")
function enterRebind()
    keymapselect:exit()
    keymaprebind:enter()
end

windows = {}
prevwindow = nil

-- Don't bind directly in here because it will trigger on keyup, not
-- keydown. This makes it feel laggy.
keymapselect = hs.hotkey.modal.new()
keymaprebind = hs.hotkey.modal.new()

hs.hotkey.bind({"ctrl"}, "t", function() keymapselect:enter() end)

keymapselect:bind("", "t", literal)
keymapselect:bind("ctrl", "t", other)
keymapselect:bind("", "w", showWindows)
keymapselect:bind("", "r", reloadConfig)
keymapselect:bind("", "escape", function() keymapselect:exit() end)

for i = 0, 9 do
   keymapselect:bind("", tostring(i), function() selectWinNumber(i) end)
   keymapselect:bind("ctrl", tostring(i), function() selectWinNumber(i) end)
end

keymapselect:bind("", "n", enterRebind)
keymapselect:bind("ctrl", "n", enterRebind)

keymaprebind:bind("", "escape", function() keymaprebind:exit() end)
for i = 0, 9 do
   keymaprebind:bind("", tostring(i), function() rebind(i) end)
end

function keymapselect:entered()
   drawSquarePointer()
end

function keymapselect:exited()
   deleteSquarePointer()
end

function keymaprebind:entered()
   drawSquarePointer()
end

function keymaprebind:exited()
   deleteSquarePointer()
end
