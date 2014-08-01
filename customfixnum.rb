module CustomFixnumForTime
  refine Fixnum do
    def minute
      self * 60
    end

    def hour
      minute * 60
    end

    def day
      hour * 24
    end

    def ago
      DateTime.now - self
    end
  end
end
