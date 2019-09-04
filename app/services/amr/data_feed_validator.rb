module Amr
  class DataFeedValidator
    def initialize(config, array_of_rows)
      @config = config
      @array_of_rows = array_of_rows
    end

    def perform
      @array_of_rows = sort_out_off_by_one_array(@array_of_rows) if @config.handle_off_by_one
      @array_of_rows.shift(@config.number_of_header_rows)
      @array_of_rows.delete_if { |row| invalid_row?(row) }
      @array_of_rows
    end

  private

    def sort_out_off_by_one_array(array_of_rows)
      array_of_rows.each_cons(2) do |row, next_row|
        # row has 48 readings, but first is from the day before
        # remove that one
        row.slice!(index_of_midnight_for_off_by_one)
        # Add that first one from the next day to the end of todays
        row << next_row[index_of_midnight_for_off_by_one]
      end

      array_of_rows.last.slice!(index_of_midnight_for_off_by_one)
      array_of_rows.last << "0.0"
      array_of_rows
    end

    def index_of_midnight_for_off_by_one
      @index_of_midnight_for_off_by_one || @config.header_example.split(',').find_index(@config.reading_fields.first)
    end

    def invalid_row?(row)
      row.empty? || row[@config.mpan_mprn_index].blank?
    end
  end
end
