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
    request_url = "#{search_url}#{search_term}+#{exclude_words}&_udhi=#{max_price}&LH_ItemCondition=3"
    page = mechanize.get(request_url)
    results = page.search('//a[@class="s-item__link"]')
    results.each do |result|
      url = result.attributes['href'].value
      csv << [url]
    end
  end
end
