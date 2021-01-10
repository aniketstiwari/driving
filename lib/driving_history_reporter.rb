require_relative 'driving_history_calculator'
#require 'pry'

input_lines = []
File.foreach("input.txt") {|line| input_lines << line.chomp}
driving_history_calculator = DrivingHistoryCalculator.new
report_lines = driving_history_calculator.calc(input_lines)
report_lines.each {|line|
  puts line
}