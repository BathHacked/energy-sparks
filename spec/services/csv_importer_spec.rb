require 'rails_helper'
require 'fileutils'
require 'fakefs/spec_helpers'

describe CsvImporter do
  include FakeFS::SpecHelpers

  let(:file_name) { 'example.csv' }
  let!(:config) {
    AmrDataFeedConfig.new(
      area_id: 2,
      description: 'Banes',
      s3_folder: 'banes',
      s3_archive_folder: 'archive-banes',
      local_bucket_path: 'tmp/amr_files_bucket/banes',
      access_type: 'SFTP',
      date_format: "%b %e %Y %I:%M%p",
      mpan_mprn_field: 'M1_Code1',
      reading_date_field: 'Date',
      reading_fields: "[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]".split(','),
      msn_field: 'M1_Code2',
      provider_id_field: 'ID',
      total_field: 'Total Units',
      meter_description_field: 'Location',
      postcode_field: 'PostCode',
      units_field: 'Units',
      header_example: "ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2"
    )
  }

  before(:each) do
    FileUtils.mkdir_p config.local_bucket_path
  end

  def example_csv
    <<~HEREDOC
      ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
    HEREDOC
  end

  def example_banes_csv
    <<~HEREDOC
      ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"

      (3794 rows affected)
    HEREDOC
  end

  def example_duff_csv
    <<~HEREDOC
      ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030348","E10BG50326"
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030349","E10BG50326"
    HEREDOC
  end

  def example_banes_csv_duplicates
    <<~HEREDOC
      ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
      (3794 rows affected)
    HEREDOC
  end

  def example_banes_no_header
    <<~HEREDOC
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"

      (3794 rows affected)
    HEREDOC

  end

  # Different total and first reading
  def example_upsert_file_2
    <<~HEREDOC
      ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2
      "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.872","0.166","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
    HEREDOC
  end

  def write_file_and_expect_readings(csv, config)
    record_count = write_file_and_parse(csv, config)
    expect(AmrDataFeedReading.count).to be 1
    expect(record_count).to be 1
    expect(AmrDataFeedReading.first.readings.first).to eq "0.165"
    expect(AmrDataFeedImportLog.count).to be 1
    log = AmrDataFeedImportLog.first
    expect(log.file_name).to eq file_name
    expect(log.amr_data_feed_config_id).to be config.id
    expect(log.records_imported).to be 1
  end

  def write_file_and_expect_updated_readings(csv, config)
    write_file_and_parse(csv, config)
    expect(AmrDataFeedReading.count).to be 1
    expect(AmrDataFeedReading.first.readings.first).to eq "0.166"
    expect(AmrDataFeedImportLog.count).to be 2
    log = AmrDataFeedImportLog.first
    expect(log.file_name).to eq file_name
    expect(log.amr_data_feed_config_id).to be config.id
    expect(log.records_imported).to be 1
  end

  def write_file_and_parse(csv, config)
    file = File.write("#{config.local_bucket_path}/#{file_name}", csv)

    importer = CsvImporter.new(config, file_name)
    importer.parse
    importer.inserted_record_count
  end

  it 'should parse a simple file' do
    write_file_and_expect_readings(example_csv, config)
  end

  it 'should handle banes format' do
    write_file_and_expect_readings(example_banes_csv, config)
  end

  it 'should handle duplicate records cleanly' do
    write_file_and_expect_readings(example_banes_csv_duplicates, config)
  end

  it 'should handle no header if config set' do
    write_file_and_expect_readings(example_banes_no_header, config)
  end

  it 'should handle graceful failure' do
    record_count = write_file_and_parse(example_duff_csv, config)
    expect(AmrDataFeedReading.count).to be 1
    expect(record_count).to be 1
    log = AmrDataFeedImportLog.first
    expect(log.file_name).to eq file_name
    expect(log.amr_data_feed_config_id).to be config.id
    expect(log.records_imported).to be 1
  end

  it 'should upsert if appropriate' do
    write_file_and_expect_readings(example_banes_csv, config)
    write_file_and_expect_updated_readings(example_upsert_file_2, config)
    expect(AmrDataFeedReading.first.readings.first).to eq "0.166"
  end
end