namespace :amr_frome_historical do
  desc "Import data from csv"
  task create_config: [:environment] do
    puts "Make sure Frome historical daily feed csv config is set up"
    puts DateTime.now.utc

    area = CalendarArea.find_by(title: 'Frome')

    AmrDataFeedConfig.where(
      area_id: area.id,
      description: 'Frome Historical',
      s3_folder: 'frome-historical',
      s3_archive_folder: 'archive-frome-historical',
      local_bucket_path: 'tmp/amr_files_bucket/frome-historical',
      access_type: 'Email',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'Site Id',
      msn_field: 'Meter Number',
      reading_date_field: 'Reading Date',
      reading_fields:  '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(','),
      header_example: "Site Id,Meter Number,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30",
    ).first_or_create

    puts DateTime.now.utc
    puts "Frome historical csv config is set up"
  end
end
