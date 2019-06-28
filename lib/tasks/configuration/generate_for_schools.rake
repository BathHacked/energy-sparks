namespace :configuration do
  desc 'Run alerts job'
  task generate_for_schools: [:environment] do
    puts Time.zone.now
    School.all.each do |school|
      puts "Running all configuration creation for #{school.name}"
      begin
        Schools::GenerateConfiguration.new(school).generate
      rescue => exception
        puts "Generation of configuration failure for #{school.name} because #{exception.message}"
      end
    end
    puts Time.zone.now
  end
end
