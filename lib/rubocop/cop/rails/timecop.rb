# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      class Timecop < Cop
        FREEZE_MESSAGE = 'Use `freeze_time` instead of `Timecop.freeze`'
        FREEZE_WITH_ARGUMENTS_MESSAGE = 'Use `travel` or `travel_to` instead of `Timecop.freeze`'
        RETURN_MESSAGE = 'Use `travel_back` instead of `Timecop.return`'
        TRAVEL_MESSAGE = 'Use `travel` or `travel_to` instead of `Timecop.travel`. If you need time to keep flowing, ' \
          'simulate it by travelling again.'
        MSG = 'Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`'

        FREEZE_TIME = 'freeze_time'
        TRAVEL_BACK = 'travel_back'

        TIMECOP_PATTERN_STRING = <<~PATTERN
          (const {nil? (:cbase)} :Timecop)
        PATTERN

        def_node_matcher :timecop, TIMECOP_PATTERN_STRING

        def_node_matcher :timecop_send, <<~PATTERN
          (send
            #{TIMECOP_PATTERN_STRING} ${:freeze :return :travel}
            $...
          )
        PATTERN

        def on_const(node)
          return unless timecop(node)

          timecop_send(node.parent) do |message, arguments|
            return on_timecop_send(node.parent, message, arguments)
          end

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            timecop_send(node) do |message, arguments|
              case message
              when :freeze
                autocorrect_freeze(corrector, node, arguments)
              when :return
                autocorrect_return(corrector, node, arguments)
              end
            end
          end
        end

        private

        def on_timecop_send(node, message, arguments)
          case message
          when :freeze
            on_timecop_freeze(node, arguments)
          when :return
            on_timecop_return(node, arguments)
          when :travel
            on_timecop_travel(node, arguments)
          else
            add_offense(node)
          end
        end

        def on_timecop_freeze(node, arguments)
          if arguments.empty?
            add_offense(node, message: FREEZE_MESSAGE)
          else
            add_offense(node, message: FREEZE_WITH_ARGUMENTS_MESSAGE)
          end
        end

        def on_timecop_return(node, _arguments)
          add_offense(node, message: RETURN_MESSAGE)
        end

        def on_timecop_travel(node, _arguments)
          add_offense(node, message: TRAVEL_MESSAGE)
        end

        def autocorrect_freeze(corrector, node, arguments)
          return unless arguments.empty?

          corrector.replace(receiver_and_message_range(node), FREEZE_TIME)
        end

        def autocorrect_return(corrector, node, _arguments)
          corrector.replace(receiver_and_message_range(node), TRAVEL_BACK)
        end

        def receiver_and_message_range(node)
          # FIXME: There is probably a better way to do this
          # Just trying to get the range of `Timecop.method_name`, without args, or block, or anything
          node.location.expression.with(end_pos: node.location.selector.end_pos)
        end
      end
    end
  end
end
