class Light < Actor
  def power
    super || 100
  end
end
