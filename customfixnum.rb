module CustomFixnumForTime
  refine Fixnum do
    def minute
      self * 60
    end
    def ago
      Time.now - self
    end
  end
end
