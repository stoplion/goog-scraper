require 'sinatra'
require 'roo'
require 'byebug'
require 'nokogiri'
require 'watir-webdriver'
require 'uri'

get '/' do
  @csvList = Array.new

  path_to_spreadsheet = 'spreadsheets/ProspectList_GooglePlaces.xlsx'
  xlsx = Roo::Spreadsheet.open(path_to_spreadsheet)

  # Add max_rows: N to limit the number
  xlsx.each_row_streaming(offset: 0) do |row|
    restName = row[1].to_s == "NULL" ? "" : row[1]
    restAddress = row[11].to_s == "NULL" ? "" : row[11]
    restCity = row[12].to_s == "NULL" ? "" : row[12]
    restState = row[13].to_s == "NULL" ? "" : row[13]
    restLocation = "#{restName} restaurant #{restAddress} #{restCity} #{restState}"

    query = "https://www.google.com/#q=#{ URI::encode(restLocation) }"

    browser = Watir::Browser.new :firefox
    browser.goto query
    sleep 3

    page = Nokogiri::HTML.parse(browser.html)


    rest_price_and_short_desc = page.css('._mr._Wfc.vk_gy').text

    if rest_price_and_short_desc.match("·")
      strArr = rest_price_and_short_desc.split("·")
      if(strArr.length > 0)
        price = strArr[0]
        shortDesc  = strArr[1]
      end
    else
      shortDesc = rest_price_and_short_desc
    end

    price = price || ""
    rest_description = page.css('._N1d').text
    rest_hours_open = page.css('._YMh').text
    restCopy = shortDesc.gsub(/\,/,"") + " - " + rest_description.gsub(/\,/,"")

    @csvList << [restName.to_s, restCopy, price, rest_hours_open]
    puts [restName.to_s, restCopy, price, rest_hours_open]
    browser.close
  end

  erb :home
end


__END__

@@home
  <b>name, description, price, hours open</b><br/>
  <% @csvList.each do |row| %>
    <%= row.join(', ') %><br/>
  <% end %>
