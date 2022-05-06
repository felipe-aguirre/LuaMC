-- V 0.3
salidaIzquierda = "left"
salidaDerecha = "right"
entrada = "front"
iluminacion = "bottom"

-- Colores
white   = colors.white
orange  = colors.orange
magenta = colors.magenta
lightBlue = colors.lightBlue
yellow  = colors.yellow
lime    = colors.lime
pink    = colors.pink
gray    = colors.gray	
lightGray = colors.lightGray
cyan    = colors.cyan
purple  = colors.purple
blue    = colors.blue
brown   = colors.brown
green   = colors.green
red     = colors.red
black   = colors.black


-- Limpia las salidas de redstone a valor 0
function cleanOutputs()
  rs.setBundledOutput(salidaIzquierda,0)
  rs.setBundledOutput(salidaDerecha,0)
  rs.setBundledOutput(iluminacion,0)
end


function redstoneDetector()
  while true do
    os.pullEvent(redstone)
  end
end

function Output(cable, color)
  cablesUsados = rs.getBundledOutput(cable)
  print(cablesUsados)
end

function intermitente()
  while true do
    enable(salida, yellow)
    sleep(0.5)
    disable(salida, yellow)
    enable(salida,magenta)
    sleep(0.5)
    disable(salida,magenta)
  end
end

-- Funciones para activar y desactivar salidas de canales de Redstone
function enable(cable, color)
  rs.setBundledOutput(cable, colors.combine(redstone.getBundledOutput(cable), color)) 
end

function disable(cable, color)
  rs.setBundledOutput(cable,colors.subtract(rs.getBundledOutput(cable),color)) 
end

-- Funcion para revisar si la entrada color esta ON
function check(cable, color)
  return colors.test(rs.getBundledInput(cable), color)
end

Mechanism = {}
function Mechanism:new (o, name, cableBoton, colorBoton, cableEntrada, colorEntrada, cableSalida, colorSalida, cableMaquina, colorMaquina, cableLuzRoja, colorLuzRoja, cableLuzVerde, colorLuzVerde)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.statusEnabled = false
  self.statusOverflow = false
  self.statusLackMaterial = false

  self.name = name or ""
  self.cableBoton = cableBoton or 0
  self.colorBoton = colorBoton or 0

  self.cableEntrada = cableEntrada or 0
  self.colorEntrada = colorEntrada or 0

  self.cableSalida = cableSalida or 0
  self.colorSalida = colorSalida or 0

  self.cableMaquina = cableMaquina or 0
  self.colorMaquina = colorMaquina or 0

  self.cableLuzRoja = cableLuzRoja or 0
  self.colorLuzRoja = colorLuzRoja or 0

  self.cableLuzVerde = cableLuzVerde or 0
  self.colorLuzVerde = colorLuzVerde or 0
  return o
end
-- Nota: La maquina se apaga al enviar un ON al redstone de maquina
-- (Va invertido enable = redstoneOFF, disable = redstoneON)
function Mechanism:enable()
  print("Prendiendo maquina - "..self.name)
  self.statusEnabled = true
  disable(self.cableMaquina, self.colorMaquina)
  enable(self.cableLuzVerde, self.colorLuzVerde)
end

function Mechanism:disable()
  self.statusEnabled = false
  print("Apagando maquina - "..self.name)
  enable(self.cableMaquina, self.colorMaquina)
  disable(self.cableLuzVerde, self.colorLuzVerde)
end

function Mechanism:checkStartup()
  local enabled = check(self.cableBoton, self.colorBoton)
  if enabled then
    Mechanism:enable()
  else
    Mechanism:disable()
  end
end

function Mechanism:checkOverflow()

end

function checkLackMaterial()

end

cleanOutputs()
  -- KM = KineticMechanism
  KMcableBoton = entrada
  KMcolorBoton = yellow

  -- En Create - Andesite Funnel representa la entraada
  KMcableEntrada = entrada
  KMcolorEntrada = lightGray

  -- En Create - Smart Chute representa la salida
  KMcableSalida = entrada
  KMcolorSalida = magenta

  -- En Create - Small Cogwheel representa la maquina
  KMcableMaquina = salidaIzquierda
  KMcolorMaquina = yellow

  KMcableLuzRoja = iluminacion
  KMcolorLuzRoja = yellow
  
  KMcableLuzVerde = iluminacion
  KMColorLuzVerde = lightGray

  KineticMechanism = Mechanism:new(
    nil,
    "Kinetic Mechanism",
    KMcableBoton, KMcolorBoton,
    KMcableEntrada, KMcolorEntrada,
    KMcableSalida, KMcolorSalida, 
    KMcableMaquina, KMcolorMaquina,
    KMcableLuzRoja, KMcolorLuzRoja,
    KMcableLuzVerde, KMColorLuzVerde
  )

while true do

  os.pullEvent("redstone") -- Espera a algun cambio en la entrada
  Mechanism:checkStartup()

--parallel.waitForAny(tick, wait_for_q)
end
