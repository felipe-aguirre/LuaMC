-- Copyright DiabolusNeil 2013
-- GitHub Get 1.0 | Last Updated Nov 23, 2013
-- Protected by GNU LGPL: bit.ly/1aYgQky
 
if not http then
  print("ERROR: Requires HTTP API to be enabled")
  return
end
 
local tArgs = {...}
if #tArgs < 2 or #tArgs > 2 then
  print("Gets raw data from Github")
  print("Usage: github <file path> <program>")
  print("\nTIP!")
  print("https://raw.github.com/<file path>")
  return
end
 
local response = function()
  local cResponse = http.get(
  "raw.github.com/DiabolusNeil/computercraft/master/test.lua"
  )
  if not cResponse then
    return
  else
    return true
  end
end
 
local getData = function()
  local gData = http.get(
  "https://raw.github.com/"..tArgs[1]
  )
  if not gData then
    return
  else
    return gData.readAll()
  end
end
 
if fs.exists(tArgs[2]) then
  print("ERROR: File already exists")
  return
end
 
if not response then
  print("ERROR: No response from Github")
  return
end
 
if not getData() then
  print("ERROR: Specified path does not exist")
  return
end
 
local file = fs.open(tArgs[2],"w")
file.write(getData())
file.close()
print("Success! Downloaded '"..tArgs[2].."'")