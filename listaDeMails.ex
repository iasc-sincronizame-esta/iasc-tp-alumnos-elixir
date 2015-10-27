require Integer
defmodule ListaDeMails do
  def start() do
    suscriptores = []
    spawn fn -> loop(suscriptores) end
  end

  def loop(suscriptores) do
    receive do
      {:suscribir, suscriptor, pid } ->
        IO.puts "Estoy suscribiendo a #{suscriptor} con el PID #{pid}"
        loop([] ++ [ { suscriptor, pid } ])
    end
  end
end