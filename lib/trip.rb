require 'time'

class Trip

  attr_accessor :distance, :driver_name, :trip_minutes

  MINUTES_IN_AN_HOUR = 60

  def initialize(start_time=nil, end_time=nil, distance=0, driver_name=nil)
    @trip_minutes = calc_trip_minutes(start_time, end_time)
    @distance = distance
    @driver_name = driver_name
  end

  def add_distance(distance)
    @distance += distance
  end

  def add_trip_minutes(trip_minutes)
    @trip_minutes += trip_minutes
  end

  def calc_speed
    normalized_trip_minutes = normalize_trip_minutes
    normalized_trip_minutes > 0 ? (@distance / normalized_trip_minutes) : nil
  end

  private
  def calc_trip_minutes(start_time, end_time)
    (end_time - start_time) / MINUTES_IN_AN_HOUR
  end

  def normalize_trip_minutes
    @trip_minutes / MINUTES_IN_AN_HOUR
  end
end