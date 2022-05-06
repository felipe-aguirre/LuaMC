if not http then
  print("ERROR: Requiere la API HTTP habilitada")
  return
end
 
local tArgs = {...}
if #tArgs < 1 or #tArgs > 1 then
  print("Importa archivos de mi Github LuaMC")
  print("Uso: github <file name>")
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
  "https://raw.github.com/felipe-aguirre/LuaMC/main/"..tArgs[1]..".lua"
  )
  if not gData then
    return
  else
    return gData.readAll()
  end
end
 
if fs.exists(tArgs[1]) then
  fs.delete(tArgs[1])
  print("ERROR: Archivo ya existe, reemplazando")
end
 
if not response then
  print("ERROR: No hay respuesta de Github")
  return
end
 
if not getData() then
  print("ERROR: Archivo no existe")
  return
end
 
local file = fs.open(tArgs[1],"w")
file.write(getData())
file.close()
print("Se logró descargar '"..tArgs[1].."'")