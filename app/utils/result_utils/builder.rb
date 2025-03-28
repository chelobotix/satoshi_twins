module ResultUtils
  module Builder
    private

    def failure(message: 'error')
      Result.new(success: false, error: message)
    end

    def success(data: {})
      Result.new(success: true, data: data)
    end
  end
end
