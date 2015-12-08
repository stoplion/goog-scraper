require 'sinatra'
require 'google_places'
require 'roo'

GP_API_KEY = 'AIzaSyDA8RxO4Lvf2Xpn-JUtivA8qpG4oqEF7VA'

get '/' do
  @client = GooglePlaces::Client.new(GP_API_KEY)
  @path_to_spreadsheet = 'spreadsheets/ProspectList_GooglePlaces.xlsx'
  @xlsx = Roo::Spreadsheet.open(@path_to_spreadsheet)

  erb :home
end


__END__

@@home
<% @xlsx.each_row_streaming(offset: 1, max_rows: 3) do |row| %>

  <% restName = row[1].to_s == "NULL" ? "" : row[1] %>
  <% restAddress = row[11].to_s == "NULL" ? "" : row[11] %>
  <% restCity = row[12].to_s == "NULL" ? "" : row[12] %>
  <% restState = row[13].to_s == "NULL" ? "" : row[13] %>
  <% restLocation = "#{restAddress} #{restCity} #{restState}" %>

  <% @foo = @client.spots_by_query('Pizza near Miami Florida') %>
  <% puts @foo %>

  <pre>
    Name: <%= restName %><br/>
    Address: <%= restLocation %><br/>
    <span>------------------------------------------</span>
  </pre>
<% end %>


