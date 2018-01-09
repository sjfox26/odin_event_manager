require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone_number)
  only_numbers = phone_number.gsub(/\W\s?/, "")
  digit_array = only_numbers.split("")
  num_digits = digit_array.length
  if num_digits == 10
    return only_numbers
  elsif num_digits == 11 && digit_array[0] == '1'
    digit_array.shift
    number_with_no_leading_1 = digit_array.join("")
    return number_with_no_leading_1
  else
    "user entered invalid phone number"
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end


#https://github.com/SophiaLWu/project-file-IO-and-serialization-with-ruby/blob/master/event_manager/lib/event_manager.rb
def find_hour_of_day(registration_date)
  date = DateTime.strptime(registration_date, "%m/%d/%y %H:%M")
  date.strftime("%H")
  #date.hour
end

def find_day_of_week(registration_date)
  date = DateTime.strptime(registration_date, "%m/%d/%y %H:%M")
  date.strftime("%A")
end

def calculate_peak_hour(array_of_hours)
  freq_of_hours = array_of_hours.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  peak_hour = array_of_hours.max_by { |v| freq_of_hours[v] }
  #https://stackoverflow.com/questions/412169/ruby-how-to-find-item-in-array-which-has-the-most-occurrences
  puts "The peak hour for registration was: #{peak_hour}"
end

def calculate_peak_weekday(array_of_weekdays)
  freq_of_weekdays = array_of_weekdays.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  peak_weekday = array_of_weekdays.max_by { |v| freq_of_weekdays[v] }
  #https://stackoverflow.com/questions/412169/ruby-how-to-find-item-in-array-which-has-the-most-occurrences
  puts "The peak day for registration was: #{peak_weekday}"
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

#template_letter = File.read "form_letter.erb"
#erb_template = ERB.new template_letter

hour_array = []
weekday_array = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(row[:homephone])

  registration_hour = find_hour_of_day(row[:regdate])
  hour_array << registration_hour


  reg_day_of_week = find_day_of_week(row[:regdate])
  weekday_array << reg_day_of_week


  puts "#{name} #{zipcode} #{phone}, registered at this hour of the day: #{registration_hour}, on a #{reg_day_of_week}"


#  legislators = legislators_by_zipcode(zipcode)

#  form_letter = erb_template.result(binding)

#  save_thank_you_letters(id,form_letter)
end


calculate_peak_hour(hour_array)

calculate_peak_weekday(weekday_array)