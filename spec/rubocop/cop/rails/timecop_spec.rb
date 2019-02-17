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

RSpec.configure do |config|
  config.include ExpectNoCorrectionsPolyfill
end

RSpec.describe(RuboCop::Cop::Rails::Timecop, :config) do
  subject(:cop) { described_class.new(config) }

  describe 'Timecop.freeze' do
    context 'without a block' do
      context 'without arguments' do
        it 'adds an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY
        end

        it 'autocorrects to `freeze_time`' do
          expect(autocorrect_source('Timecop.freeze')).to(eq('freeze_time'))
        end

        context 'spread over multiple lines' do
          it 'adds an offense' do
            expect_offense(<<-RUBY.strip_indent)
              Timecop
              ^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
                .freeze
            RUBY
          end

          it 'autocorrects to `freeze_time`' do
            expect(autocorrect_source("Timecop\n  .freeze"))
              .to(eq('freeze_time'))
          end
        end
      end

      context 'with arguments' do
        it 'adds an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123)
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY
        end

        it 'does not autocorrect' do
          source = 'Timecop.freeze(123)'

          expect(autocorrect_source(source)).to(eq(source))
        end
      end
    end

    context 'with a block' do
      context 'without arguments' do
        it 'adds an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze { }
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY
        end

        it 'autocorrects to `freeze_time`' do
          expect(autocorrect_source('Timecop.freeze { }'))
            .to(eq('freeze_time { }'))
        end
      end

      context 'with arguments' do
        it 'adds an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Timecop.freeze(123) { }
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY
        end

        it 'does not autocorrect' do
          source = 'Timecop.freeze(123) { }'

          expect(autocorrect_source(source)).to(eq(source))
        end
      end
    end
  end

  describe 'Timecop.return' do
    context 'without a block' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          Timecop.return
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY
      end

      context 'in Rails < 6.0', :rails5 do
        it 'autocorrects to `travel_back`' do
          expect(autocorrect_source('Timecop.return')).to(eq('travel_back'))
        end

        context 'inside a block' do
          it 'autocorrects to `travel_back`' do
            expect(autocorrect_source('foo { Timecop.return }'))
              .to(eq('foo { travel_back }'))
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
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          Timecop.return { }
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY
      end

      it 'does not autocorrect' do
        expect(autocorrect_source('Timecop.return { }'))
          .to(eq('Timecop.return { }'))
      end

      context 'inside a block' do
        it 'does not autocorrect' do
          expect(autocorrect_source('foo { Timecop.return { } }'))
            .to(eq('foo { Timecop.return { } }'))
        end
      end
    end
  end

  describe 'Timecop.travel' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.travel(123) { }
        ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.travel`. If you need time to keep flowing, simulate it by travelling again.
      RUBY
    end
  end

  describe 'Timecop.*' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end

  describe 'Timecop' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end

  describe '::Timecop' do
    it 'adds an offense' do
      expect_offense(<<-RUBY.strip_indent)
        ::Timecop.foo
        ^^^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end
end
