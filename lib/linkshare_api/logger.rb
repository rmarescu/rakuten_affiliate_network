require "logger"

module LinkshareAPI
  class Logger
    attr_reader :logger

    def self.log(level, message)

      new.logger.send(level, "[linkshare_api] #{message}")
    end

    def initialize
      @logger = LinkshareAPI.logger || ::Logger.new(STDOUT)
    end
  end
end
