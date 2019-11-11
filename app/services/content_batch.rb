class ContentBatch
  def initialize(schools = School.all)
    @schools = schools
  end

  def generate
    @schools.each do |school|
      Rails.logger.info "Running for #{school.name}"
      # Aggregate school
      aggregate_school = AggregateSchoolService.new(school).aggregate_school

      Rails.logger.info "Aggregated school"

      # Configuration school
      suppress_output { Schools::GenerateConfiguration.new(school, aggregate_school).generate }

      Rails.logger.info "Generated configuration"

      # Generate alerts
      suppress_output { Alerts::GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated alerts"

      # Generate equivalences
      suppress_output { Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated equivalences"

      # Generate content
      generate_content(school)

      Rails.logger.info "Generated content"
    end
  end

  private

  def generate_content(school)
    if Time.zone.today.wednesday?
      subscription_frequency = if school.holiday_approaching?
                                 [:weekly, :termly, :before_each_holiday]
                               else
                                 [:weekly]
                               end
      Rails.logger.info "Generated alert content, including #{subscription_frequency.to_sentence} subscriptions"
      Alerts::GenerateContent.new(school).perform(subscription_frequency: subscription_frequency)
    else
      Rails.logger.info "Generated alert content, without subscriptions"
      Alerts::GenerateContent.new(school).perform(subscription_frequency: [])
    end
  end

  def suppress_output
    original_stdout = $stdout.clone
    original_stderr = $stderr.clone
    $stderr.reopen File.new('/dev/null', 'w')
    $stdout.reopen File.new('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen original_stdout
    $stderr.reopen original_stderr
  end
end