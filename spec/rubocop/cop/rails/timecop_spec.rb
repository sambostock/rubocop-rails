# frozen_string_literal: true

module ExpectNoCorrectionsPolyfill
  private

  # yoiked from https://github.com/rubocop-hq/rubocop/pull/6752, following
  # https://github.com/rubocop-hq/rubocop-rails/pull/38#issuecomment-464438473
  def expect_no_corrections
    unless @processed_source
      raise '`expect_no_correctionss` must follow `expect_offense`'
    end

    return if cop.corrections.empty?

    # In order to print a nice diff, e.g. what source got corrected to,
    # we need to run the actual corrections

    corrector =
      RuboCop::Cop::Corrector.new(@processed_source.buffer, cop.corrections)
    new_source = corrector.rewrite

    expect(new_source).to eq(@processed_source.buffer.source)
  end
end

require 'pry'

RSpec.configure do |config|
  # binding.pry

  config.include ExpectNoCorrectionsPolyfill
end

RSpec.describe RuboCop::Cop::Rails::Timecop do
  subject(:cop) { described_class.new }

  describe 'Timecop.freeze' do
    context 'without a block' do
      context 'without arguments' do
        it 'adds an offense, and corrects to `freeze_time`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            freeze_time
          RUBY
        end

        context 'spread over multiple lines' do
          it 'adds an offense, and corrects to `freeze_time`' do
            expect_offense(<<-RUBY.strip_indent)
              Timecop
              ^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
                .freeze
            RUBY

            expect_correction(<<-RUBY.strip_indent)
              freeze_time
            RUBY
          end
        end
      end

      context 'with arguments' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123)
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'with a block' do
      context 'without arguments' do
        it 'adds an offense, and autocorrects to `freeze_time`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze { }
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            freeze_time { }
          RUBY
        end
      end

      context 'with arguments' do
        it 'adds an offense, and does not autocorrect' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123) { }
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  describe 'Timecop.return' do
    context 'without a block' do
      context 'in Rails < 6.0', :rails5 do
        it 'adds an offense, and corrects to `travel_back`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.return
            ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            travel_back
          RUBY
        end

        context 'inside a block' do
          it 'adds an offense, and corrects to `travel_back`' do
            expect_offense(<<-RUBY.strip_indent)
              foo { Timecop.return }
                    ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
            RUBY

            expect_correction(<<-RUBY.strip_indent)
              foo { travel_back }
            RUBY
          end
        end
      end

      context 'in Rails >= 6.0', :rails6 do
        it 'adds an offense, and corrects to `travel_back`' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.return
            ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            travel_back
          RUBY
        end

        context 'inside a block' do
          it 'adds an offense, and corrects to `travel_back`' do
            expect_offense(<<-RUBY.strip_indent)
              foo { Timecop.return }
                    ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
            RUBY

            expect_correction(<<-RUBY.strip_indent)
              foo { travel_back }
            RUBY
          end
        end
      end

      # context 'in Rails > 6.0', :rails6 do
      #   it 'autocorrects to `unfreeze`' do
      #     expect(autocorrect_source('Timecop.return')).to(eq('unfreeze'))
      #   end

      #   context 'inside a block' do
      #     it 'autocorrects to `unfreeze`' do
      #       expect(autocorrect_source('foo { Timecop.return }'))
      #         .to(eq('foo { unfreeze }'))
      #     end
      #   end
      # end
    end

    context 'with a block' do
      it 'adds an offense, and does not correct' do
        expect_offense(<<-RUBY.strip_indent)
          Timecop.return { }
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY

        expect_no_corrections
      end

      context 'inside a block' do
        it 'adds an offense, and does not correct' do
          expect_offense(<<-RUBY.strip_indent)
            foo { Timecop.return { } }
                  ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  describe 'Timecop.travel' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.travel(123) { }
        ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.travel`. If you need time to keep flowing, simulate it by travelling again.
      RUBY

      expect_no_corrections
    end
  end

  describe 'Timecop.*' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe 'Timecop' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe '::Timecop' do
    it 'adds an offense, and does not correct' do
      expect_offense(<<-RUBY.strip_indent)
        ::Timecop.foo
        ^^^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY

      expect_no_corrections
    end
  end

  describe 'Foo::Timecop' do
    it 'adds no offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Foo::Timecop
      RUBY
    end
  end
end
