entradaIzquierda = "left"
entradaDerecha = "right"
salida = "front"
iluminacion = "bottom"


-- Limpia las salidas de redstone a valor 0
function cleanOutputs()
  rs.setBundledOutput(salida,0)
  rs.setBundledOutput(iluminacion,0)
end


function redstoneDetector()
  while true do
    os.pullEvent(redstone)
  end

function Output(cable, color)
  cablesUsados = rs.getBundledOutput(cable)
  print(cablesUsados)
end

function intermitente()
  while true do
    rs.setBundledOutput(salida, colors.yellow)
    sleep(0.5)
    rs.setBundledOutput(salida,colors.magenta)
    sleep(0.5)
  end
end


cleanOutputs()

while true do
  -- KM = KineticMechanism
  KMBoton = rs.getBundledInput(entradaIzquierda, colors.yellow)
  Output(salida, colors.magenta)
  rs.setBundledOutput(salida, colors.magenta)
  Output(salida, colors.magenta)
  os.pullEvent("redstone")
  -- PM = Precision Mechanism

--parallel.waitForAny(tick, wait_for_q)
end
