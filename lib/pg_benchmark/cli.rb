module PgBenchmark
  class CLI < Thor
    desc "db_name benchmark_name records", "Run the benchmark with the given number of records"
    def benchmark(db_name, benchmark_name, records)
      time = BenchmarkManager.new(
        db_name,
        benchmark_name,
        records
      ).run

      puts time
    end
  end
end

