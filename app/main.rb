require 'json'
require 'stringio'
$LOAD_PATH.concat(Dir.glob File.expand_path("#{File.dirname __FILE__}/ruby/*/gems/**/lib/"))
$LOAD_PATH << APP_DIR_PATH = File.expand_path("#{File.dirname __FILE__}/")
require 'sinatra/base'
import 'org.bukkit.Bukkit'

class LingrBot < Sinatra::Base
  get '/' do
    {RUBY_DESCRIPTION: RUBY_DESCRIPTION, bukkit_version: Bukkit.getBukkitVersion}.inspect
  end

  post '/' do
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
    EventHandler.reload
  end

  post '/eval' do
    str = request.body.string
    p [:eval, str]
    EventHandler.module_eval(str).inspect
  end
end

Thread.start do
  Rack::Handler::WEBrick.run LingrBot, Port: 8126, AccessLog: [], Logger: WEBrick::Log.new("/dev/null")
end

require 'event_handler'
EventHandler # this is necessary
