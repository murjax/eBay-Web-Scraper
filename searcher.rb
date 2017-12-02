require 'Nokogiri'
require 'HTTParty'
require 'mechanize'

puts "Please enter your search term"
search_term = gets
puts "Please enter words to exclude from search results (separated by commas, no spaces)"
exclude_words = gets
puts "Please enter maximum price (integer amount only)"
max_price = gets

search_term = search_term.gsub(' ', '+')
exclude_words = "-#{exclude_words.gsub(',', '+-')}"
mechanize = Mechanize.new
search_url = 'https://www.ebay.com/sch/?_nkw='
page = mechanize.get("#{search_url}#{search_term}+#{exclude_words}&LH_BIN=1&_udhi=#{max_price}")
results = page.search('//li[@class="sresult lvresult clearfix li"]')
puts "There are #{results.count} results"
results.each do |result|
  url = result.children[1].children[1].children[1].attributes.first[1].value
  puts "#{url}\n\n" unless url.include?('pulsar')
end
