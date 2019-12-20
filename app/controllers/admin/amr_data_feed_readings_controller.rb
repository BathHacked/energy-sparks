module Admin
  class AmrDataFeedReadingsController < AdminController
    def create
      amr_upload_reading = AmrUploadedReading.find(params[:amr_uploaded_reading_id])

      amr_data_feed_import_log = AmrDataFeedImportLog.create(
        amr_data_feed_config_id: amr_upload_reading.amr_data_feed_config_id,
        file_name: amr_upload_reading.file_name,
        import_time: DateTime.now.utc
        )

      records_before = AmrDataFeedReading.count

      @upserted_record_count = Amr::DataFeedUpserter.new(amr_upload_reading.reading_data, amr_data_feed_import_log.id).perform
      @inserted_record_count = AmrDataFeedReading.count - records_before

      amr_data_feed_import_log.update(records_imported: @inserted_record_count, records_upserted: @upserted_record_count)

      amr_upload_reading.update!(imported: true)

      redirect_to admin_amr_data_feed_config_path(amr_upload_reading.amr_data_feed_config_id), notice: "We have inserted #{@inserted_record_count} records and updated #{@upserted_record_count} records"
    end
  end
end