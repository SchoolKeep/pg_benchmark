INSERT INTO authors (id, name) VALUES (1, 'George Orwell');

<% records.times do |n| %>
  INSERT INTO books (name, author_id)
  VALUES ('Book Title <%= n %>', 1);
<% end %>
