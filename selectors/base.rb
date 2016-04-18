class Selector
  def to_s
    return @str if @str
    @str = self.get_str
  end
end