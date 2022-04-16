require 'pry'
require 'nokogiri'
require 'httparty'
require 'mechanize'

item_list_file = 'ebay_search_list.csv'
mechanize = Mechanize.new
search_url = 'https://www.ebay.com/sch/?_nkw='

last_results = CSV.read('ebay_results_list.csv') if File.exist?('ebay_results_list.csv')
new_item_count = 0

CSV.open('ebay_results_list.csv', 'wb') do |csv|
  if last_results
    last_results.each do |row|
      csv << row
    end
  end

  last_result_titles = last_results&.map { |row| row.first } || []
  last_result_urls = last_results&.map { |row| row.last } || []

  CSV.foreach(item_list_file) do |row|
    search_term = row[0].gsub(' ', '+')
    exclude_words = "-#{row[1].gsub(' ', '+-')}"
    max_price = row[2]
    request_url = "#{search_url}#{search_term}+#{exclude_words}&_udhi=#{max_price}&_sop=10"
    page = mechanize.get(request_url)

    results = page.search('//a[@class="s-item__link"]')

    results.each do |result|
      title = result.children.find('//h3').first.text
      next if title == 'Shop on eBay'

      full_url = result.attributes['href'].value
      item_id = full_url.gsub(/\d+((.|,)\d+)?/).first
      url = "https://www.ebay.com/itm/#{item_id}"

      next if last_result_urls.include?(url)

      new_item_count += 1
      next_row = [title, url]
      csv << [title, url]
    end
  end
end

File.open('history.log', 'a') do |file|
  file.puts "#{Time.now.to_s}: #{new_item_count} items added"
end
