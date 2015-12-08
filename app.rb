require 'sinatra'
require 'roo'
require 'mechanize'
require 'open-uri'

get '/' do
  @path_to_spreadsheet = 'spreadsheets/ProspectList_GooglePlaces.xlsx'
  @xlsx = Roo::Spreadsheet.open(@path_to_spreadsheet)

  agent = Mechanize.new do |agent|
    agent.user_agent_alias = 'Mac Safari'
  end

  agent.get('http://google.com/') do |page|
    @search_result = page.form_with(:name => 'f') do |search|
      search.q = 'Hello world'
    end.submit
  end
  erb :home
end


__END__

@@home
  <% @search_result.links.each do |link| %>
    <%= puts link.text %>
  <% end %>
