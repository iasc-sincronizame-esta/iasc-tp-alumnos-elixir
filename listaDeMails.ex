require Integer

defmodule ListaDeMails do
  def start() do
    suscriptores = []
    consultas = []
    spawn fn -> loop({ suscriptores, consultas }) end
  end

  def loop({ suscriptores, consultas }) do
    receive do
      { :suscribir, pidSuscriptor } ->
        IO.puts "Se suscribió alguien"
        suscriptores = suscriptores ++ [ pidSuscriptor ]
        loop({ suscriptores, consultas})

      { :listar, pid } ->
        send pid, suscriptores
        loop({ suscriptores, consultas})

      { :consultar, consulta, pidAlumno } ->
        IO.puts "Están consultando #{consulta}"
        consultas = consultas ++ [ { consulta, pidAlumno } ]
        loop({ suscriptores, consultas})
    end
  end
end

# ---

defmodule Alumno do
  def start() do
    spawn fn -> loop() end
  end

  def loop() do
    receive do
      { :consultar, lista, consulta } ->
        send lista, { :consultar, consulta, self }
        loop()
    end
  end
end

laLista = ListaDeMails.start()
unAlumno = Alumno.start()
send unAlumno, { :consultar, laLista, "¿Cuál es el sentido de la vida?" }
