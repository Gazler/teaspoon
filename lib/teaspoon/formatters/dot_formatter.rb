module Teaspoon
  module Formatters
    class DotFormatter < Base

      RED = 31
      GREEN = 32
      YELLOW = 33
      CYAN = 36

      protected

      def log_spec(result)
        return log_str(".", GREEN) if result.passing?
        return log_str("*", YELLOW) if result.pending?
        log_str("F", RED)
      end

      def log_error(result)
        log_line(result.message, RED)
        for trace in result.trace || []
          log_line("  # #{filename(trace["file"])}:#{trace["line"]}#{trace["function"].present? ? " -- #{trace["function"]}" : ""}", CYAN)
        end
        log_line
      end

      def log_console(message)
        log_str(message)
      end

      def log_result(result)
        log_line("\n")
        log_information
        log_stats(result)
        log_failed_examples
      end

      private

      def log_information
        log_pending if pendings.size > 0
        log_failures if failures.size > 0
      end

      def log_pending
        log_line("Pending:")
        pendings.each do |result|
          log_line("  #{result.description}", YELLOW)
          log_line("    # Not yet implemented\n", CYAN)
        end
      end

      def log_failures
        log_line("Failures:\n")
        failures.each_with_index do |failure, index|
          log_line("  #{index + 1}) #{failure.description}")
          log_line("     Failure/Error: #{failure.message}\n", RED)
        end
      end

      def log_stats(result)
        log_line("Finished in #{result.elapsed} seconds")
        stats = "#{pluralize("example", run_count)}, #{pluralize("failure", failures.size)}"
        stats << ", #{pendings.size} pending" if pendings.size > 0
        log_line(stats, stats_color)
      end

      def log_failed_examples
        return if failures.size == 0
        log_line
        log_line("Failed examples:\n")
        failures.each do |failure|
          log_line("teaspoon -s #{@suite_name} --filter=\"#{failure.link}\"", RED)
        end
      end

      def stats_color
        failures.size > 0 ? RED : pendings.size > 0 ? YELLOW : GREEN
      end
    end
  end
end
