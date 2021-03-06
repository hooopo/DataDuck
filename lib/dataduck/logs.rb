require 'logger'
require 'raven'

if ENV['AIRBRAKE_PROJECT_ID'] && ENV['AIRBRAKE_PROJECT_KEY']
  require 'airbrake'

  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_PROJECT_ID']
    c.project_key = ENV['AIRBRAKE_PROJECT_KEY']
  end
end

module DataDuck
  module Logs
    @@ONE_MB_IN_BYTES = 1048576

    @@logger = nil

    def Logs.ensure_logger_exists!
      log_file_path = DataDuck.project_root + '/log/dataduck.log'
      DataDuck::Util.ensure_path_exists!(log_file_path)
      @@logger ||= Logger.new(log_file_path, shift_age = 100, shift_size = 100 * @@ONE_MB_IN_BYTES)
    end

    def Logs.debug(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)

      puts "[DEBUG] #{ message }"
      @@logger.debug(message)
    end

    def Logs.info(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)

      puts "[INFO] #{ message }"
      @@logger.info(message)
    end

    def Logs.warn(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)

      puts "[WARN] #{ message }"
      @@logger.warn(message)
    end

    def Logs.error(err, message = nil)
      self.ensure_logger_exists!
      message = err.to_s unless message
      message = Logs.sanitize_message(message)

      puts "[ERROR] #{ message }"
      @@logger.error(message)

      Logs.third_party_error_tracking!(err)
    end

    private

      def Logs.third_party_error_tracking!(err)
        if ENV['SENTRY_DSN']
          Raven.capture_exception(err)
        end

        if ENV['AIRBRAKE_PROJECT_ID'] && ENV['AIRBRAKE_PROJECT_KEY']
          Airbrake.notify_sync(err)
        end
      end

      def Logs.sanitize_message(message)
        message = message.gsub(/aws_access_key_id=[^';]+/, "aws_access_key_id=******")
        message = message.gsub(/AWS_ACCESS_KEY_ID=[^';]+/, "AWS_ACCESS_KEY_ID=******")
        message = message.gsub(/aws_secret_access_key=[^';]+/, "aws_secret_access_key=******")
        message = message.gsub(/AWS_SECRET_ACCESS_KEY=[^';]+/, "AWS_SECRET_ACCESS_KEY=******")
        message
      end
  end
end
