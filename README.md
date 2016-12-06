# PgBenchmark

A Postgres benchmarking tool

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_benchmark'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_benchmark

## Usage

```bash
$ bundle exec pgb [database_name] [benchmark_name] [records]
```

`pg_benchmark` searches the current working directory, then recursively up the 
hierachy for a directory called `pg_benchmarks`. Once found it expects a directory 
matching `[benchmark_name]` where it will execute `.sql` files with the following order:

1. `drop_schema.sql` (required)
2. `create_schema.sql` (required)
3. `create_constraints.sql` (optional)
4. `create_indexes.sql` (optional)
5. `create_triggers.sql` (optional)
6. `insert_data.sql` (optional)
7. `snapshot.sql` (optional)
8. `benchmark.sql` (required)
9. `drop_schema.sql` (required)

It logs information including: progress, record counts and the data snapshot to 
`stderr`. And the time to run `benchmark.sql` to `stdout`.

```bash
$ bundle exec pgb benchmark_database triggers 1_000
dropping schema...
creating schema...
inserting data...
creating constraints...
creating indexes...
creating triggers...
--------------------
activities count: 100
completions count: 10000
course_attempts count: 1000
courses count: 1
sections count: 10
--------------------
{"progress"=>"0.000"}
--------------------
starting benchmark
finished benchmark
--------------------
activities count: 101
completions count: 10000
course_attempts count: 1000
courses count: 1
sections count: 10
--------------------
{"progress"=>"0.099"}
--------------------
dropping schema...
0.3970880000015313
```

If you would like to hide the debug information you can redirect `stderr` to `/dev/null`.

```bash
$ bundle exec pgb benchmark_database triggers 1_000 2> /dev/null
0.3970880000015313
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schoolkeep/pg_benchmark.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
