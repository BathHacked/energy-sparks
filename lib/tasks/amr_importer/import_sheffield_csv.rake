namespace :amr_sheffield do
  desc "Import data from csv"
  task :import_csv, [:readings_date] => :environment do |_t, args|
    puts "Make sure Sheffield set up"
    puts DateTime.now.utc
    # Set this up, just in case it isn't already
    sheffield_config = AmrDataFeedConfig.set_up_sheffield

    readings_date = DateTime.parse(args[:readings_date]).utc.strftime('%Y%m%d') || DateTime.yesterday.strftime('%d-%m-%Y')
    file_name = "4003063_9232_Export_#{readings_date}.csv"
    file_name_and_path = "amr_files_bucket/#{file_name}"

    # 4003063_9232_Export_20181104_120347_747

    # Does file exist? If not, get it from S3
    get_file_from_s3(file_name, file_name_and_path) unless Pathname.new(file_name_and_path).exist?

    if Pathname.new(file_name_and_path).exist?
      we_have_a_file_so_import(sheffield_config, file_name)
    else
      puts "Missing file, not local or in S3 #{file}"
    end
    puts DateTime.now.utc
  end

  def get_file_from_s3(file_name, file_name_and_path)
    puts "No file, so let's download from S3 #{file_name}"
    region = 'eu-west-2'
    bucket = ENV['AWS_S3_AMR_DATA_FEEDS_BUCKET']
    key = "sheffield/#{file_name}"
    s3 = Aws::S3::Client.new(region: region)
    s3.get_object(bucket: bucket, key: key, response_target: file_name_and_path)
    puts "Downloaded"
  end

  def we_have_a_file_so_import(config, file_name)
    importer = CsvImporter.new(config, file_name)
    importer.parse

    puts "imported"
  end
end
