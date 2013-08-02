module LinkshareAPI
  class Error < StandardError
    attr_reader :message, :code

    def initialize(message = nil, code = nil)
      @message = message
      @code    = code
    end

    def to_s
      code_string = code.nil? ? "" : " (Code #{code})"
      "#{message}#{code_string}"
    end
  end
end
