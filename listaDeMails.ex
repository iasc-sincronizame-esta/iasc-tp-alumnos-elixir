require Integer

defmodule ListaDeMails do
  def start() do
    suscriptores = []
    spawn fn -> loop(suscriptores) end
  end

  def loop(suscriptores) do
    receive do
      { :suscribir, suscriptor, pid } ->
        loop(suscriptores ++ [ { suscriptor, pid } ])

      { :listar, pid } ->
        send pid, suscriptores
        loop(suscriptores)
    end
  end
end

# ---

a = ListaDeMails.start()
