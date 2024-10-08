# frozen_string_literal: true

require_relative './helpers/cli_inputs'
require_relative './helpers/files'
require_relative './helpers/formatting'
require_relative './helpers/group_ownership'
require_relative './helpers/event_options'
require_relative './helpers/metric_options'
require_relative './helpers/service_ping_dashboards'

module InternalEventsCli
  module Helpers
    include CliInputs
    include Files
    include Formatting
    include GroupOwnership
    include EventOptions
    include MetricOptions
    include ServicePingDashboards

    MILESTONE = File.read('VERSION').strip.match(/(\d+\.\d+)/).captures.first
    NAME_REGEX = /\A[a-z0-9_]+\z/

    def new_page!(page = nil, total = nil, steps = [])
      cli.say TTY::Cursor.clear_screen
      cli.say TTY::Cursor.move_to(0, 0)
      cli.say "#{progress_bar(page, total, steps)}\n" if page && total
    end
  end
end
