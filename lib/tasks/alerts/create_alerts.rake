namespace :alerts do
  desc 'Run alerts job'
  task create: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running all alerts for #{school.name}"
      Alerts::GenerateAndSaveAlerts.new(school).perform
    end
    puts Time.zone.now
  end
end
