require "rubygems"
require "bundler"
require "yaml"
Bundler.require

configure do
  db = Sequel.connect('sqlite://db.db')

  db.create_table? :users do
    primary_key   :id

    String    :name
    String    :lastname
    String    :user_name, unique: true
    String    :password
    String    :email
    String    :phone
    String    :user_type
  end

  set :db, db
  set :twilio, YAML.load(File.open("./twilio.yaml").read)
  set :session_secret, "dyydofew9fykdhfskdf 6587"
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

  if params[:pass1] != params[:pass2]
    return redirect to "/sign_up"
  end

  data[:password] = BCrypt::Password.create(params[:pass1])
  data.delete 'pass1'
  data.delete 'pass2'

  # TODO: Dar formato especifico al numero de telefono

  dbu = settings.db[:users]

  begin
    dbu.insert(data)
  rescue Sequel::UniqueConstraintViolation => e
    puts e
    return "Ese nombre de usuario ya existe"
  else
    redirect to "/login?success=true"
  end
end


get "/login" do
  #el usuario se registra con sus datos
  #formulario de username y password con boton de submit

  erb :login, locals: {
    error: params[:error],
    success: params[:success]
  }
end

post "/login" do
  # el sistema veifica los datos del login
  # si es válido el usuario: te manda selección de team
  # si no te regresa a /login?error=true
  
  dbu = settings.db[:users]
  user = dbu.filter({user_name: params[:user_name]}).first

  return redirect(to "/login?error=true") if user.nil?
  
  puts user[:password]

  if user && BCrypt::Password.new(user[:password]) == params[:password]
    session[:user] = user
    redirect to "/emergency"
  else
    redirect to "/login?error=true"
  end
end



get "/emergency" do
  # muestra botón para crear emergency
  return redirect to "/login" unless session[:user]
  # TODO: mostrar lista de team leaders en un drop box de base de datos
end

post "/emergency" do
  return redirect to "/login" unless session[:user]
  #se verifica que se declaró un codigo_ami
  #boton de cancelar codigo_ami
  #muestra pantalla para seleccionar el team
  #Se confirma el team seleccionado (team_leader, team_members)
  #Boton para notificar al team con SMS
  #se mandan SMS a team
  #se verifica respuesta de team leader

  # TODO: Obtener usuario de params[:user]

  rcpt = "?"
  client = Twilio::REST::Client.new settings.twilio[:sid], settings.twilio[:token]
  sms = {
    from: settings.twilio[:number],
    to: rcpt,
    body: "Las clases del Rob están dando frutos"
  }
  client.account.messages.create(sms)
end

