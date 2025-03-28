module ResultUtils
  module Builder
    private

    def failure(data: { status: "error" })
      Result.new(success: false, error: data)
    end

    def success(data: {})
      Result.new(success: true, data: data)
    end
  end
end
