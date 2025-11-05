# frozen_string_literal: true

require 'active_support/notifications'
require 'active_support/isolated_execution_state'

module InstrumentationHelper
  # Captures instrumentation events emitted during the block execution
  #
  # @param pattern [String, Regexp] Pattern to match event names (default: /zendesk\./)
  # @yield Block during which events will be captured
  # @return [Array<Array>] Array of [event_name, payload] tuples
  #
  # @example
  #   events = capture_instrumentation_events do
  #     client.connection.get('path')
  #   end
  #   event_name, payload = events.first
  #
  def capture_instrumentation_events(pattern = /zendesk\./)
    events = []

    ActiveSupport::Notifications.subscribed(
      lambda { |name, _start, _finish, _id, payload|
        events << [name, payload]
      },
      pattern
    ) do
      yield
    end

    events
  end

  # Finds the first event matching the given name
  #
  # @param events [Array<Array>] Array of [event_name, payload] tuples
  # @param name [String] Event name to find
  # @return [Array, nil] The [event_name, payload] tuple or nil if not found
  #
  def find_event(events, name)
    events.find { |(event_name, _payload)| event_name == name }
  end

  # Finds all events matching the given name
  #
  # @param events [Array<Array>] Array of [event_name, payload] tuples
  # @param name [String] Event name to filter by
  # @return [Array<Array>] Array of matching [event_name, payload] tuples
  #
  def filter_events(events, name)
    events.select { |(event_name, _payload)| event_name == name }
  end
end
