class RegisterRequestJob < ApplicationJob
  queue_as :low_priority

  def perform(remote_ip, origin, url, payload, status_code, time_total)
    Request.new({ ip: remote_ip,
                  origin: origin,
                  url: url,
                  payload: payload,
                  status_code: status_code,
                  time_total: time_total
                }).save
  end
end
