prefix = {
   mods={"ctrl"},
   key="t",
}

windows = {}
prevwindow = nil
squareDrawing = nil

function notify(msg)
   hs.alert.show(msg)
end

function deleteSquarePointer()
   squareDrawing:delete()
   squareDrawing = nil
end

function drawSquarePointer()
   if squareDrawing then
      deleteSquarePointer()
   end

   -- Get the current co-ordinates of the mouse pointer
   mousepoint = hs.mouse.absolutePosition()
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
         if s ~= "" then
            s = s .. "\n"
         end
         s = s .. tostring(i) .. " - " .. windows[i]:title()
      end
   end
   notify(s)
   keymapselect:exit()
end

function findWindow(window)
   local MAXWINDOWS <const> = 9
   for i = 0, MAXWINDOWS do
      if windows[i] == window then
         return i
      end
   end

   return -1
end

function rebind(n)
   window = hs.window.focusedWindow()

   -- unbind if it's already bound
   i = findWindow(window)
   if i ~= -1 then
      windows[i] = nil
   end

   windows[n] = window
   notify("Bound " .. window:title() .. " to " .. n)
   keymaprebind:exit()
end

function selectwin(w)
   focused = hs.window.focusedWindow()
   if focused ~= w then
      prevwindow = focused
   end
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

function prefixAction()
   keymapselect:enter()
end

function literal()
   -- exit first, otherwise the keyStroke is caught by the keymap again
   keymapselect:exit()
   hs.hotkey.deleteAll(prefix["mods"], prefix["key"])
   hs.eventtap.keyStroke(prefix["mods"], prefix["key"])
   hs.hotkey.bind(prefix["mods"], prefix["key"], prefixAction)
   keymapselect:bind(prefix["mods"], prefix["key"], other)
end

function enterRebind()
    keymapselect:exit()
    keymaprebind:enter()
end

-- watchers
-- appWatchers = {}
-- windowWatchers = {}
-- local events = hs.uielement.watcher

-- function appWatcherCallback(appName, eventType, appObject)
--    -- if eventType == events.applicationActivated then
--    if eventType == hs.application.watcher.activated then
--       appWatchers[appObject:pid()] = true
--       notify("switched to " .. appName .. " " .. tablelength(appWatchers) .. " " .. type(appObject))

--       -- windowWatchers = appObject:newWatcher(windowWatcherCallback)
--    end
-- end

-- function handleAppEvent(element, eventType, watcher, info)
--    notify("appEvent on " .. element:id())
-- end
function windowCreatedCallback(window, appName, event)
   i = 0
   while windows[i] do
      i = i + 1
   end
   notify("created window for " .. appName .. " is number " .. i)
   windows[i] = window
end

function windowDestroyedCallback(window, appName, event)
   i = findWindow(window)
   if i ~= -1 then
      windows[i] = nil
   end

   notify("destroyed window for " .. appName .. " was number " .. i)
end

hs.window.filter.new():subscribe({
      windowCreated=windowCreatedCallback,
      windowDestroyed=windowDestroyedCallback
})

-- Don't bind directly in here because it will trigger on keyup, not
-- keydown. This makes it feel laggy.
keymapselect = hs.hotkey.modal.new()
keymaprebind = hs.hotkey.modal.new()

hs.hotkey.bind(prefix["mods"], prefix["key"], prefixAction)

keymapselect:bind("", "t", literal)
keymapselect:bind(prefix["mods"], prefix["key"], other)
keymapselect:bind("", "w", showWindows)
keymapselect:bind("ctrl", "w", showWindows)
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
