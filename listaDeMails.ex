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
        idConsulta = make_ref
        consultas = consultas ++ [ { idConsulta, consulta, pidAlumno, [] } ]

        Enum.each suscriptores, fn it ->
          if it != pidAlumno do
            send it, { :notificacion_consulta, { idConsulta, consulta, pidAlumno } }
          end
        end

      { :responder, idConsulta, respuesta } ->
        esLaConsultaQuePiden = fn it ->
          (elem it, 0) == idConsulta
        end

        consulta = Enum.find consultas, esLaConsultaQuePiden

        if consulta != nil do
          IO.puts "Están respondiendo la consulta #{elem consulta, 1} con la respuesta #{respuesta}"
          respuestas = elem consulta, 3
          consulta = put_elem consulta, 3, respuestas ++ [ respuesta ]
          
          consultas = Enum.reject consultas, esLaConsultaQuePiden
          consultas = consultas ++ [ consulta ]
        else
          IO.puts "Quieren responder una consulta, pero la re flashearon con el id"
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

      { :notificacion_consulta, { id, consulta, pidAlumno } } ->
        IO.puts "Se ve que alguien preguntó #{consulta}"
        loop()
    end
  end
end

# ---

defmodule Docente do
  def start() do
    spawn fn -> loop() end
  end

  def loop() do
    receive do
      { :responder, lista, idConsulta, respuesta } ->
        send lista, { :responder, idConsulta, respuesta }
        loop()

      { :notificacion_consulta, { id, consulta, pidAlumno } } ->
        IO.puts "Se ve que alguien preguntó #{consulta}, estaría para contestarle, ¿no?"
        loop()
    end
  end
end

# ---

laLista = ListaDeMails.start()

alumnoPreguntadorYSuscriptor = Alumno.start()
alumnoSuscriptor = Alumno.start()

send laLista, { :suscribir, alumnoPreguntadorYSuscriptor }
send alumnoPreguntadorYSuscriptor, { :consultar, laLista, "¿Cuál es el sentido de la vida?" }

docente = Docente.start()

# ver qué mensajes hay y contestar alguno...

send laLista, { :listar_consultas, self }
receive do
  consultas ->
    primera = List.first consultas
    idDeLaPrimera = elem primera, 0

    send docente, { :responder, laLista, idDeLaPrimera, "La respuesta está en tu corazón (?)" }
end