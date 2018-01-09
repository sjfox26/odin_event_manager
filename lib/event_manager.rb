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

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

#template_letter = File.read "form_letter.erb"
#erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(row[:homephone])

  puts "#{name} #{zipcode} #{phone}"
#  legislators = legislators_by_zipcode(zipcode)

#  form_letter = erb_template.result(binding)

#  save_thank_you_letters(id,form_letter)
end