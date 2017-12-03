require 'Nokogiri'
require 'HTTParty'
require 'mechanize'

item_list_file = 'ebay_search_list.csv'
mechanize = Mechanize.new
search_url = 'https://www.ebay.com/sch/?_nkw='

CSV.open('ebay_results_list.csv', 'wb') do |csv|
  CSV.foreach(item_list_file) do |row|
    search_term = row[0].gsub(' ', '+')
    exclude_words = "-#{row[1].gsub(' ', '+-')}"
    max_price = row[2]
    request_url = "#{search_url}#{search_term}+#{exclude_words}&LH_BIN=1&_udhi=#{max_price}"
    page = mechanize.get(request_url)
    results = page.search('//li[contains(@class, "sresult")]')
    results.each do |result|
      url = result.children[1].children[1].children[1].attributes.first[1].value
      csv << [row[0], url] unless url.include?('pulsar') || !url.include?('https')
    end
  end
end
