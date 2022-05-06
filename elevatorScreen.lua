local apiName = "touchpoint"
local pasteLink = "pFHeia96"
local infoName = "info"
 
term.clear()
term.setCursorPos(1,1)
 
if not fs.exists(apiName) then
   shell.run("pastebin get " .. pasteLink .. " " .. apiName)   --downloads the API
end
 
os.loadAPI(apiName)
peripheral.find("modem", rednet.open)
local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.clear()
 
local monitorWidth, monitorHeight = monitor.getSize()
if monitorWidth >= 36 and monitorHeight >= 24 then   --changes text scale depending on the monitor size
   monitor.setTextScale(1)
   monitorWidth, monitorHeight = monitor.getSize()
end
 
local monitorSide
for _,name in ipairs(peripheral.getNames()) do   --gets the side the monitor is on
   if peripheral.getType(name) == "monitor" then
      monitorSide = name
   end
end
 
term.clear()
term.setCursorPos(1,1)
print("A ComputerCraft Program by Cod0fDuty")
print("Touchpoint API by Lyqyd")
print("Elevator Screen Module")
 
local floor = ""
local id = ""
local currentPage
 
while not fs.exists(infoName) or not floor or not id do   --check if file exists
   term.setCursorPos(1,6)
   term.clearLine()
   term.setCursorPos(1,5)
   term.clearLine()
   local h = fs.open("info", "w")
   term.write("Total number of floors: ")
   floor = tonumber(read())
   term.write("ID of receiving computer: ")
   id = tonumber(read())
   currentPage = 1
   local infoTable = {floor, id, currentPage}
   h.write(textutils.serialize(infoTable))
   h.close()
end
 
local h = fs.open(infoName, "r")   --reads from a file
local infoTable = textutils.unserialize(h.readAll())
if not infoTable then
   fs.delete(infoName)
   os.reboot()
end
floor = tonumber(infoTable[1])
id = tonumber(infoTable[2])
currentPage = tonumber(infoTable[3])
term.setCursorPos(1,5)
print("Total number of floors: " .. floor)
print("ID of receiving computer: " .. id)
h.close()
 
local buttonsPerColumn = math.floor((monitorHeight)/2)
local numberOfColumns = math.min(math.ceil(floor/buttonsPerColumn), 3)
local maxButtonsInOnePage = buttonsPerColumn * 3
local numberOfPages = math.ceil(floor/maxButtonsInOnePage)
local buttonWidth = monitorWidth - 2
 
if floor * 2 >= monitorHeight then
   buttonWidth = math.floor((monitorWidth-numberOfColumns - 3)/numberOfColumns)   --calculates the width of buttons
end
 
if currentPage > numberOfPages then   --if monitor size is changed, current page will be set to the maximum number of pages
   currentPage = numberOfPages
end
 
local page = {}
for i = 1, numberOfPages do
   page[i] = touchpoint.new(monitorSide)   --add pages
   if i ~= numberOfPages then
      page[i]:add(">>", nil, monitorWidth-3, monitorHeight, monitorWidth, monitorHeight, colors.black, colors.white)
   end
   if i ~= 1 then
      page[i]:add("<<", nil, 1, monitorHeight, 4, monitorHeight, colors.black, colors.white)
   end
   if numberOfPages > 1 then
      local pageLabel
      if monitorWidth == 15 then
         pageLabel = "P." .. i
      else                      --add page number
         pageLabel = "Page " .. i
      end
      page[i]:add(pageLabel, nil, 5, monitorHeight, monitorWidth-4, monitorHeight, colors.black, colors.black)
   end
end
 
local minX = 2
local minY = 1
local maxX = monitorWidth - 1
local maxY = minY
 
local pageIndex = 1
local topFloor = floor - 1
 
if topFloor < buttonsPerColumn then
   for i = topFloor, 0, -1 do
      page[pageIndex]:add(tostring(i), nil, minX, minY, maxX, maxY, colors.red, colors.lime)   --adds buttons in reverse
      minY = minY + 2
      maxY = minY
   end
else
   minX = 2
   maxX = minX + buttonWidth
   minY = monitorHeight - 1
   maxY = minY
   for i = 0, topFloor do
      page[pageIndex]:add(tostring(i), nil, minX, minY, maxX, maxY, colors.red, colors.lime)
      local remainingFloors = topFloor - i
      minY = maxY - 2
      maxY = minY
      if maxY <= 0 then   --move buttons to the next column
         minX = maxX + 2
         maxX = minX + buttonWidth
         minY = monitorHeight - 1
         maxY = minY
         if maxX > monitorWidth then   --change to next page
            pageIndex = pageIndex + 1
            minX = 2
            maxX = minX + buttonWidth
            minY = monitorHeight - 1
            maxY = minY
         end
         if remainingFloors < buttonsPerColumn then   --moves the buttons up if there are spaces
            minY = monitorHeight - 1 - ((buttonsPerColumn - remainingFloors) * 2)
            maxY = minY
         end
      end
   end
end
 
term.setCursorPos(1,8)
print("Press E to clear data...")
 
while true do
   page[currentPage]:draw()   --draws the buttons on the monitor
   local h = fs.open(infoName, "w")
   local infoTable = {floor, id, currentPage}
   h.write(textutils.serialize(infoTable))
   h.close()
   local event, p1 = page[currentPage]:handleEvents(os.pullEvent())
   if event == "button_click" then   --wait for button clicks
      local chosen = tonumber(p1)
      page[currentPage]:flash(p1)
      if chosen ~= nil then
         rednet.send(id, chosen, "call")
      elseif p1 == ">>" then
         currentPage = currentPage + 1
      elseif p1 == "<<" then
         currentPage = currentPage - 1
      end
   elseif event == "key" and p1 == keys.e then
      fs.delete(infoName)   --deletes the file
      term.setCursorPos(1,9)
      print("Cleared!")
      sleep(1)
      os.reboot()
   end
end