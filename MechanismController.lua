-- V 1.4
term.clear()
print("Bienvenido a Create Mechanism Controller")

salidaIzquierda = "left"
salidaIzquierdaValue = 0

salidaDerecha = "right"
salidaDerechaValue = 0

entrada = "front"
entradaValue = 0

iluminacion = "bottom"
iluminacionValue = 0

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
  rs.setBundledOutput(entrada,0)
  rs.setBundledOutput(iluminacion,0)
end


-- SIN USO AUN
function redstoneDetector()
  while true do
    os.pullEvent(redstone)
  end
end


-- SIN USO AUN; PARA TODO INTERMITENTE
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

function trustedInput()
  -- Revisa que el pullEvent detectado no sea por outputs
  local izquierdo = rs.getBundledOutput(salidaIzquierda)
  local derecho = rs.getBundledOutput(salidaDerecha)
  local izquierdoAntiguo = salidaIzquierdaValue
  local derechoAntiguo = salidaDerechaValue
  salidaIzquierdaValue = izquierdo
  salidaDerechaValue = derecho
  return izquierdo == izquierdoAntiguo and derecho == derechoAntiguo
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

-- Nota: La maquina se apaga al enviar un ON al redstone de maquina
-- (Va invertido enable = redstoneOFF, disable = redstoneON)
function enableMachine(M)
  print(M.name.." - Encendido")
  M.statusEnabled = true
  disable(M.cableMaquina, M.colorMaquina)
  enable(M.cableLuzVerde, M.colorLuzVerde)
end

function disableMachine(M)
  M.statusEnabled = false
  print(M.name.." - Apagado")
  enable(M.cableMaquina, M.colorMaquina)
  disable(M.cableLuzVerde, M.colorLuzVerde)
end

function alertON(M)
  -- TODO: Hacer que parpadee sin apagar el programa
  enable(M.cableLuzRoja, M.colorLuzRoja)
end

function alertOFF(M)
  disable(M.cableLuzRoja, M.colorLuzRoja)
end

function checkStartup(M)
  local enabled = check(M.cableBoton, M.colorBoton)
  if enabled and M.statusEnabled == false and M.statusLackMaterial == false and M.statusOverflow == false then
    enableMachine(M)
    return
  end
  if enabled and M.statusEnabled == true then
    disableMachine(M)
    return
  end
end

function checkOverflow(M)
  local enabled = check(M.cableSalida, M.colorSalida)
  if enabled and M.statusOverflow == false then
    -- Hay falla de falta de material de salida
    -- Apaga maquina
    print(M.name.." - Falla en salida")
    disableMachine(M)
    -- Alerta
    alertON(M)
    M.statusLackMaterial = true
    return
  end
  if (not enabled) and M.statusOverflow == true and M.statusLackMaterial == false then
    -- Se recuperó de una falla
    -- Prende maquina
    print(M.name.." - Recuperación de falla Salida")
    enableMachine(M)
    -- Apaga alerta
    alertOFF(M)
    M.statusLackMaterial = false
  end
end

function checkLackMaterial(M)
  local enabled = check(M.cableEntrada, M.colorEntrada)
  if enabled and M.statusLackMaterial == false then
    -- Hay falla de falta de material de entrada
    -- Apaga maquina
    print(M.name.." - Falla en entrada")
    disableMachine(M)
    -- Alerta
    alertON(M)
    M.statusLackMaterial = true
    return
  end
  if (not enabled) and M.statusLackMaterial == true and M.statusOverflow == false then
    -- Se recuperó de una falla
    -- Prende maquina
    print(M.name.." - Recuperación de falla Entrada")
    enableMachine(M)
    -- Apaga alerta
    alertOFF(M)
    M.statusLackMaterial = false
  end
end

cleanOutputs()
  -- KM = KineticMechanism
local KM = {
  name = "Kinetic Mechanism",
  statusEnabled = false,
  statusOverflow = false,
  statusLackMaterial = false,
  cableBoton = entrada,
  colorBoton = yellow,
  cableEntrada = entrada,
  colorEntrada = lightGray,
  cableSalida = entrada,
  colorSalida = magenta,
  cableMaquina = salidaIzquierda,
  colorMaquina = yellow,
  cableLuzRoja = iluminacion,
  colorLuzRoja = yellow,
  cableLuzVerde = iluminacion,
  colorLuzVerde = lightGray
}

local PM = {
  name =  "Precision Mechanism",
  statusEnabled = false,
  statusOverflow = false,
  statusLackMaterial = false,
  cableBoton = entrada,
  colorBoton = orange,
  cableEntrada = entrada,
  colorEntrada = black,
  cableSalida = entrada,
  colorSalida = lime,
  cableMaquina = salidaIzquierda,
  colorMaquina = orange,
  cableLuzRoja = iluminacion,
  colorLuzRoja = lime,
  cableLuzVerde = iluminacion,
  colorLuzVerde = black

}







function Kinetics()
  KineticMechanism:checkLackMaterial()
  KineticMechanism:checkOverflow()
  KineticMechanism:checkStartup()
  return
end
 


while true do
  -- Check de estados iniciales
  os.pullEvent("redstone") -- Espera a algun cambio en la entrada

  if trustedInput() then
    checkLackMaterial(KM)
    checkOverflow(KM)
    checkStartup(KM)

    checkLackMaterial(PM)
    checkOverflow(PM)
    checkStartup(PM)
  end
--parallel.waitForAny(tick, wait_for_q)
end
