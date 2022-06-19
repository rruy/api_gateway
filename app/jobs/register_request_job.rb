class RegisterRequestJob < ApplicationJob
  queue_as :low_priority

  def perform(origin, remote_ip, url, payload, status_code, time_total)
    request = Request.new(ip: remote_ip, origin: origin, url: url, payload: payload, status_code: status_code, time_total: time_total)
    request.save
  end
end
