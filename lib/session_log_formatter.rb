module Logging
  class SessionLogFormatter< Logger::Formatter
    def call(severity, time, program_name, message)
      "#{time.to_formatted_s(:db)} --#{RequestStore.store[:session_uuid]} --#{severity} #{message}\n"
    end
  end
end
