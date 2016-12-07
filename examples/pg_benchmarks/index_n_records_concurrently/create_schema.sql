CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  author_id INT
);
