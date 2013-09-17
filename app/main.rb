require 'json'
require 'stringio'
$LOAD_PATH.concat(Dir.glob File.expand_path("#{File.dirname __FILE__}/ruby/*/gems/**/lib/"))
$LOAD_PATH << APP_DIR_PATH = File.expand_path("#{File.dirname __FILE__}/")
require 'sinatra/base'
import 'org.bukkit.Bukkit'

MY_IP = '10.0.2.2' # TODO

class LingrBot < Sinatra::Base
  set :public_folder, '/home/tukushi/public_html'

  get '/' do
    halt 403 if request.ip != MY_IP
    {RUBY_DESCRIPTION: RUBY_DESCRIPTION, bukkit_version: Bukkit.getBukkitVersion}.inspect
  end

  post '/' do
    halt 403 if request.ip != MY_IP
    begin
      JSON.parse(request.body.string)['events'].map {|event|
        msg = event['message']
        next unless %w[computer_science mcujm].include? msg['room']
        EventHandler.on_lingr(msg)
        case event['message']['text']
        when '/list'
          p 'list!'
          Bukkit.getOnlinePlayers.map(&:getName).inspect
        else
          ''
        end
      }.join
    rescue => e
      p e
      ''
    end
  end

  get '/reload' do
    halt 403 if request.ip != MY_IP
    EventHandler.reload
  end

  post '/eval' do
    halt 403 if request.ip != MY_IP
    str = request.body.string
    EventHandler.module_eval(str).to_s
  end

  post '/deploy' do
    Bukkit.broadcast_message 'deploying...'
    # for some reason system() blocks.
    IO.popen 'cd ~/git/mckokoro; git pull --rebase', 'r' do |io|
      p io.read
    end
    p :pulled
    EventHandler.reload
    Job.reload
    EventHandler.broadlingr '...deployed!'
    'ok, deployed.'
  end
end

Thread.start do
  Rack::Handler::WEBrick.run LingrBot, Port: 8126, AccessLog: [], Logger: WEBrick::Log.new("/dev/null")
end

require 'event_handler'
require 'job'
EventHandler # this is necessary
