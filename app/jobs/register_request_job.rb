class RegisterRequestJob < ApplicationJob
  queue_as :low_priority

  def perform(origin, remote_ip, url, payload)
    request = Request.new(ip: remote_ip, origin: origin, url: url, payload: payload)
    request.save
  end
end
