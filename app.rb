require "rubygems"
require "bundler"


Bundler.require

configure do
  db = Sequel.connect('sqlite://db.db')

  db.create_table? :user do
    primary_key   :id

    String    :user_name
    String    :password
    String    :nombre
    String    :apellido_paterno
    String    :apellido_materno
    String    :email
    String    :user_type
    String    :phone
  end

  set :db, db
end

enable :sessions


get "/" do
  # Splash page: muestra que hace la aplicación
  # mostrar link al login
  # además, mostrar un link al registro

  erb :splash

end

get "/sign_up" do

  #cuando el usuario no tiene cuenta se registra con
  #user_type ,name ,password, numero_telefono
  #formulario para llenar los datos y un boton de submit
  #si el usuario ya tiene cuenta link a login

  erb :sign_up

end

post "/sign_up" do
  #se verifica el registro y se crea el usuario
  # redirigimos el usuario a iniciar sesión
  data = params
  data[:password] = BCrypt::Password.create(data[:pass1])

  dbu = settings.db[:user]
  user = dbu.insert(data)


end

get "/login" do
  #el usuario se registra con sus datos
  #formulario de username y password con boton de submit

  erb :login

end

post "/login" do
  #el sistema veifica los datos del login
  # si es válido el usuario: te manda a?
  # si no te regresa a /login?fail=true
  
  dbu = settings.db[:user]
  user = dbu.filter({email: params[:user_name]}).first

  if user_name && BCrypt::Password.new(user_name.password) == params[:password]
    session[:user_name] = user_name
    redirect to "/emergency"
  else
    redirect to "/login"
  end

end

get "/emergency" do

  # muestra botón para crear emergency
  
  unless session[:user_name]
    return redirect to "/login"
  end

  <<-HTML
  Si pudimos!!!!
  HTML
  
end

post "/emergency" do
  #se verifica que se declaró un codigo_ami
  #boton de cancelar codigo_ami
  #muestra pantalla para seleccionar el team
  #Se confirma el team seleccionado (team_leader, team_members)
  #Boton para notificar al team con SMS
  #se mandan SMS a team
  #se verifica respuesta de team leader

end

=begin

get "/emergency/aceptar" do
  #solo lo puede aceptar doctor
  #cuando se acepta, se notifica a team
end

get "/emergency/rechazar" do
  #cuando el usuario rechaza el team no es notificado
end

get "/teams" do
  #nos da los integrantes del equipo
end

get "/teams/members" do
  #se puede agregar integrantes del equipo 
  #(hemodinamista (1), segundo operador (1-2), anestesiólogo(1))
end

get "/teams/members/new" do
  # te muestra formulario de invitación a miembro nuevo
end

post "/teams/members/new" do
  # crea una invitación a un miembro nuevo
  # y la manda por mail
end

get "/emergency/:paciente" do |paciente|

end
=end
