require 'upsert'
require 'upsert/active_record_upsert'
require 'upsert/connection/postgresql'
require 'upsert/connection/PG_Connection'
require 'upsert/merge_function/PG_Connection'
require 'upsert/column_definition/postgresql'
require 'csv'

class CsvImporter
  attr_reader :inserted_record_count

  def initialize(config, file_name)
    @file_name = file_name
    @config = config
    @map_of_fields_to_indexes = @config.map_of_fields_to_indexes
    @inserted_record_count = 0
    @existing_records = AmrDataFeedReading.count
    @meter_id_hash = Meter.all.map { |m| [m.meter_no.to_s, m.id]}.to_h
    @header_first_thing = @config.header_example.split(',').first
  end

  def parse
    Rails.logger.info "Loading: #{@config.local_bucket_path}/#{@file_name}"
    amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @config.id, file_name: @file_name, import_time: DateTime.now.utc)

    Upsert.batch(AmrDataFeedReading.connection, AmrDataFeedReading.table_name) do |upsert|
      begin
        CSV.foreach("#{@config.local_bucket_path}/#{@file_name}", col_sep: @config.column_separator, row_sep: :auto).with_index do |row, row_number|
          create_record(upsert, row, amr_data_feed_import_log.id, row_number)
        end
      rescue CSV::MalformedCSVError
        Rails.logger.error "Malformed CSV"
      end
    end
    @inserted_record_count = AmrDataFeedReading.count - @existing_records
    amr_data_feed_import_log.update(records_imported: @inserted_record_count)
    @inserted_record_count
  end

private

  def row_is_header?(row, row_number)
    row_number == 0 && row[0] == @header_first_thing
  end

  def invalid_row?(row)
    row.empty? || row[@map_of_fields_to_indexes[:mpan_mprn_index]].blank? || readings_as_array(row).compact.nil?
  end

  def create_record(upsert, row, amr_data_feed_import_log_id, row_number)
    return if row_is_header?(row, row_number)
    return if invalid_row?(row)

    readings = readings_as_array(row)

    mpan_mprn = row[@map_of_fields_to_indexes[:mpan_mprn_index]]
    reading_date_string = row[@map_of_fields_to_indexes[:reading_date_index]]

    meter_id = @meter_id_hash[mpan_mprn]

    # This determines which row to select, values get updated for this particular row
    unique_record_selector = { mpan_mprn: mpan_mprn, reading_date: reading_date_string }

    upsert.row(unique_record_selector,
      amr_data_feed_config_id: @config.id,
      meter_id: meter_id,
      mpan_mprn: mpan_mprn,
      reading_date: reading_date_string,
      postcode: fetch_from_row(:postcode_index, row),
      units: fetch_from_row(:units_index, row),
      description: fetch_from_row(:description_index, row),
      meter_serial_number: fetch_from_row(:meter_serial_number_index, row),
      provider_record_id: fetch_from_row(:provider_record_id_index, row),
      readings: readings,
      amr_data_feed_import_log_id: amr_data_feed_import_log_id,
      created_at: DateTime.now.utc,
      updated_at: DateTime.now.utc
    )
  end

  def fetch_from_row(index_symbol, row)
    return if @map_of_fields_to_indexes[index_symbol].nil?
    row[@map_of_fields_to_indexes[index_symbol]]
  end

  def readings_as_array(row)
    @config.array_of_reading_indexes.map { |reading_index| row[reading_index] }
  end
end
