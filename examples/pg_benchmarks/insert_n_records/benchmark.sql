<% records.times do |n| %>
  INSERT INTO people (name) VALUES ('Person <%= n %>');
<% end %>
