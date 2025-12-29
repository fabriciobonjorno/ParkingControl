# frozen_string_literal: true

module Parkings
  class DurationService
    MINIMUM_MINUTES = 1

    def self.call(started_at:, left_at: nil)
      new(started_at, left_at).call
    end

    def initialize(started_at, left_at)
      @started_at = started_at
      @left_at    = left_at
    end

    def call
      return format_minutes(MINIMUM_MINUTES) unless @started_at

      total_minutes = ((end_time - @started_at) / 60).ceil
      total_minutes = [ total_minutes, MINIMUM_MINUTES ].max

      format_minutes(total_minutes)
    end

    private

    def end_time
      @left_at || Time.zone.now
    end

    def format_minutes(minutes)
      "#{minutes} #{minutes == 1 ? 'minuto' : 'minutos'}"
    end
  end
end
