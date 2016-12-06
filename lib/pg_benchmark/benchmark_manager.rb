class BenchmarkManager
  extend Forwardable

  BENCHMARK_DIR = "pg_benchmarks".freeze
  BENCHMARK_SQL = "benchmark.sql".freeze
  CREATE_CONSTRAINTS_SQL = "create_constraints.sql".freeze
  CREATE_INDEXES_SQL = "create_indexes.sql".freeze
  CREATE_SCHEMA_SQL = "create_schema.sql".freeze
  CREATE_TRIGGERS_SQL = "create_triggers.sql".freeze
  DROP_SCHEMA_SQL = "drop_schema.sql".freeze
  INSERT_DATA_SQL = "insert_data.sql".freeze
  SNAPSHOT_SQL = "snapshot.sql".freeze

  def initialize(database_name, benchmark_name, records)
    @database_name = database_name
    @benchmark_name = benchmark_name
    @records = records.to_i
  end

  def run
    chdir_benchmarks

    setup
    log_data_counts
    log_data_snapshot

    benchmark_times = run_benchmark

    log_data_counts
    log_data_snapshot

    log sub_section
    drop_schema

    benchmark_times.real
  end

  private

  attr_reader :benchmark_name, :database_name, :records
  def_delegators :conn, :exec

  def conn
    @conn ||= PG.connect(dbname: database_name)
  end

  def setup
    drop_schema
    create_schema
    insert_data
    create_constraints
    create_indexes
    create_triggers
  end

  def drop_schema
    log "dropping schema..."
    exec erb(DROP_SCHEMA_SQL)
  end

  def create_schema
    log "creating schema..."
    exec erb(CREATE_SCHEMA_SQL)
  end

  def insert_data
    if File.exists?(INSERT_DATA_SQL)
      log "inserting data..."
      exec erb(INSERT_DATA_SQL)
    else
      log "skipping insert data..."
    end
  end

  def create_constraints
    if File.exists?(CREATE_CONSTRAINTS_SQL)
      log "creating constraints..."
      exec erb(CREATE_CONSTRAINTS_SQL)
    else
      log "skipping create constraints..."
    end
  end

  def create_indexes
    if File.exists?(CREATE_INDEXES_SQL)
      log "creating indexes..."
      exec erb(CREATE_INDEXES_SQL)
    else
      log "skipping create indexes..."
    end
  end

  def create_triggers
    if File.exists?(CREATE_TRIGGERS_SQL)
      log "creating triggers..."
      exec erb(CREATE_TRIGGERS_SQL)
    else
      log "skipping create triggers..."
    end
  end

  def run_benchmark
    log sub_section

    log "starting benchmark"
    times = with_times(erb(BENCHMARK_SQL))
    log "finished benchmark"

    times
  end

  def erb(file)
    contents = File.read(file)
    ERB.new(contents, 0, "").result(binding)
  end

  def tables
    results = exec <<~SQL
      SELECT tablename
      FROM pg_tables
      WHERE schemaname = 'public'
      ORDER BY tablename ASC;
    SQL

    results.map { |result| result["tablename"] }
  end

  def log_data_counts
    log sub_section

    tables.each do |table_name|
      results = exec "SELECT COUNT(*) AS count FROM #{table_name};"
      count = results[0]["count"]

      log "#{table_name} count: #{count}"
    end
  end

  def log_data_snapshot
    log sub_section

    if File.exists?(SNAPSHOT_SQL)
      result = exec erb(SNAPSHOT_SQL)
      log result.to_a
    else
      log "skipping snapshot..."
    end
  end

  def chdir_benchmarks
    if Dir.exist? BENCHMARK_DIR
      Dir.chdir BENCHMARK_DIR
      if Dir.exist?(benchmark_name)
        Dir.chdir benchmark_name
      else
        raise "Could not find benchmark directory #{benchmark_name}"
      end
    elsif Dir.pwd == "/"
      raise "Could not find pg_benchmarks directory #{BENCHMARK_DIR}"
    else
      Dir.chdir("..")
      chdir_benchmarks
    end

    def with_times(sql)
      Benchmark.measure do
        exec(sql)
      end
    end

    def log(message)
      $stderr.puts(message)
    end

    def section
      log "."*60
    end

    def sub_section
      "-"*20
    end
  end
end
