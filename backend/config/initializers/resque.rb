require 'rufus'

Resque.redis = configatron.redis.url
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
Resque.logger.level = Logger::INFO
Resque.schedule = YAML.load_file('config/daily_schedule.yml')
