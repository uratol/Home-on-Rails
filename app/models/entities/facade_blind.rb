class FacadeBlind < Device

  register_attributes :min_tilt, :max_tilt, :tilt_up_full_time, :tilt_down_full_time, :azimuth
  register_events :at_finish
  validate :driver_valid?

  def init
    super
    self.binary = false
  end

  def tiltable?
    driver == 'bidirectional_tilt_motor'
  end

  def tilt
  end

  private

  def driver_valid?
    unless ['bidirectional_motor', 'bidirectional_tilt_motor'].include?(driver)
      errors.add(:driver, "Driver \"#{ driver }\" is not valid")
    end
  end

end