require 'sinatra'
require 'roo'
require 'mechanize'
require 'open-uri'
require 'byebug'


get '/' do
  @path_to_spreadsheet = 'spreadsheets/ProspectList_GooglePlaces.xlsx'
  @xlsx = Roo::Spreadsheet.open(@path_to_spreadsheet)

  @agent = Mechanize.new do |agent|
    agent.user_agent_alias = 'Mac Safari'
  end

  @xlsx.each_row_streaming(offset: 1, max_rows: 3) do |row|
    restName = row[1].to_s == "NULL" ? "" : row[1]
    restAddress = row[11].to_s == "NULL" ? "" : row[11]
    restCity = row[12].to_s == "NULL" ? "" : row[12]
    restState = row[13].to_s == "NULL" ? "" : row[13]
    restLocation = "#{restName} #{restAddress} #{restCity} #{restState}"


    @agent.get('http://google.com/') do |page|
      @search_result = page.form_with(:name => 'f') do |search|
        search.q = restLocation
      end.submit
      byebug
      restDescription = page.at('._N1d')
    end
  end



  erb :home
end


__END__

@@home
  <% @search_result.links.each do |link| %>
    <%= puts link.text %>
  <% end %>
