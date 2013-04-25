require 'json'
$LOAD_PATH.concat Dir.glob File.expand_path '~/git/mcsakura/src/ruby/2.1.0/gems/**/lib/'
require 'sinatra/base'
import 'org.bukkit.Bukkit'

class LingrBot < Sinatra::Base
  set :port, 8126
  set :run, true

  get '/' do
    p 'yay!'
    'ok'
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
          Bukkit.getOnlinePlayers.to_a.map(&:getName).inspect
        else
          ''
        end
      }.join
    rescue => e
      p e
      ''
    end
  end

  Thread.start do
    run!
  end
end

module EventHandler
  module_function
  def on_load(plugin)
    @plugin = plugin
    p :on_load, plugin
  end

  def on_lingr(message)
  end

  def on_async_player_chat(evt)
    p :chat, evt.getPlayer
  end

  def on_player_login(evt)
    p :login, evt
    p evt.getPlayer
  end
end

EventHandler
