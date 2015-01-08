require 'webmachine'
require 'time'
require 'logger'

class LogListener
  def call(*args)
    handle_event(Webmachine::Events::InstrumentedEvent.new(*args))
  end

  def handle_event(event)
    request = event.payload[:request]
    resource = event.payload[:resource]
    code = event.payload[:code]

    puts '[%s] method=%s uri=%s code=%d resource=%s time=%.4f' % [
        Time.now.iso8601, request.method, request.uri.to_s, code, resource,
        event.duration
      ]
  end
end

Webmachine::Events.subscribe('wm.dispatch', LogListener.new)

