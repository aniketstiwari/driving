require 'time'
require "./trip"

class DrivingHistoryCalculator

  def calc(lines)
    default_trips = create_default_trips_from_drivers(lines)
    trips = collect_trips(lines)
    summarized_trips = summarize_trips(trips)
    sorted_trips = sort_trips(default_trips.merge(summarized_trips).values)
    create_reportable_trips(sorted_trips)
    end

    private

    RECORD_SPLIT_PATTERN = ' '
    COMMAND_DRIVER = 'Driver'
    DRIVER_NAME_INDEX = 1
    START_TIME_INDEX = 2
    END_TIME_INDEX = 3
    TRIP_DISTANCE_INDEX = 4
    MINIMUM_SPEED = 5
    MAXIMUM_SPEED = 100
    VALID_TRIP_LINE_REGEX = /^Trip\s.*\s\d{2}:\d{2}\s\d{2}:\d{2}\s.*\d\.?\d*/

    def create_default_trips_from_drivers(lines)
      lines.select{ |line|
        line.start_with? COMMAND_DRIVER
      }.map{ |driver|
        driver_tokens = driver.split(RECORD_SPLIT_PATTERN)
        driver_name = driver_tokens[DRIVER_NAME_INDEX]
        trip_data = default_trip_data
        trip_data.driver_name = driver_name
        {driver_name => trip_data}
      }.reduce({}, :merge)
    end

    def collect_trips(lines)
      lines.select{ |line|
        VALID_TRIP_LINE_REGEX =~ line
      }.map {|trip_record|
        trip_tokens = trip_record.split(RECORD_SPLIT_PATTERN)
        distance = trip_tokens[TRIP_DISTANCE_INDEX].to_f
        start_time = Time.parse(trip_tokens[START_TIME_INDEX])
        end_time = Time.parse(trip_tokens[END_TIME_INDEX])
        driver_name = trip_tokens[DRIVER_NAME_INDEX]
        trip = Trip.new(start_time, end_time, distance, driver_name)
        { driver_name => trip }
      }.reject {|trip|
        speed = trip[trip.keys[0]].calc_speed()
        speed == nil || speed < MINIMUM_SPEED || speed > MAXIMUM_SPEED
      }
    end

    def summarize_trips(trips)
      trips.reduce({}) {|trip_summaries,trip|
        driver_name = trip.keys[0]
        if (!trip_summaries[driver_name])
          trip_data = default_trip_data
          trip_data.driver_name = driver_name
          trip_summaries[driver_name] = trip_data
        end

        update_summary_distance(trip_summaries, trip, driver_name)
        update_summary_minutes(trip_summaries, trip, driver_name)

        trip_summaries
      }
    end

    def update_summary_distance(trip_summaries, trip, driver_name)
      trip_summaries[driver_name].add_distance(trip[driver_name].distance)
    end

    def update_summary_minutes(trip_summaries, trip, driver_name)
      trip_summaries[driver_name].add_trip_minutes(trip[driver_name].trip_minutes)
    end

    def sort_trips(trips)
      trips.sort{|trip1,trip2| trip2.distance <=> trip1.distance}
    end

    def create_reportable_trips(driver_trips)
      reported_trips = driver_trips.map {|value|
        speed = value.calc_speed
          if (speed)
            "#{value.driver_name}: #{value.distance.round.to_i} miles @ #{speed.round.to_i} mph"
          else
            "#{value.driver_name}: #{value.distance.round.to_i} miles"
          end
        }

      reported_trips
    end

    def default_trip_data
      default_time = Time.now
      Trip.new(default_time, default_time, 0, nil)
    end
end
