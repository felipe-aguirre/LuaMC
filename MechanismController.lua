entradaIzquierda = "left"
entradaDerecha = "right"
salida = "front"
iluminacion = "bottom"


-- Limpia las salidas de redstone a valor 0
function cleanInput()
  rs.setBundledOutput(salidas,0)
  rs.setBundledOutput(iluminacion,0)
end

cleanOutputs()

while true do
  -- KM = KineticMechanism
  KMBoton = rs.getBundledInput(entradaIzquierda, colors.yellow)

  if KMBoton then
    rs.setBundledOutput(salidas, colors.yellow)
    sleep(2)
    rs.setBundledOutput(salidas,colors.magenta)
    sleep(2)
  else 
    rs.setBundledOutput(salidas, 0)
  end

  -- PM = Precision Mechanism

end
