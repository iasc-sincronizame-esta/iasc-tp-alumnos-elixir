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

      { :listar_suscriptores, pid } ->
        send pid, suscriptores

      { :listar_consultas, pid } ->
        send pid, consultas

      { :consultar, consulta, pidAlumno } ->
        IO.puts "Están consultando #{consulta}"
        consultas = consultas ++ [ { consulta, pidAlumno } ]

        Enum.each suscriptores, fn it ->
          # TODO: validar que no sea el mismo
          send it, { :notificacion_consulta, { consulta, pidAlumno } }
        end
    end

    loop({ suscriptores, consultas})
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

      { :notificacion_consulta, { consulta, pidAlumno } } ->
        IO.puts "Se ve que alguien preguntó #{consulta}"
        loop()
    end
  end
end

laLista = ListaDeMails.start()
alumnoPreguntador = Alumno.start()
alumnoSuscriptor = Alumno.start()
send laLista, { :suscribir, alumnoSuscriptor }
send alumnoPreguntador, { :consultar, laLista, "¿Cuál es el sentido de la vida?" }
