module EventHandler
  module_function
  def on_load(plugin)
    @plugin = plugin
    p :on_load, plugin
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
