# frozen_string_literal: true

RSpec.describe(RuboCop::Cop::Rails::Timecop, :config) do
  subject(:cop) { described_class.new(config) }

  describe 'Timecop.freeze' do
    context 'without a block' do
      context 'without arguments' do
        it 'adds an offense' do
          expect_offense(<<~RUBY)
            Timecop.freeze
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY
        end

        it 'autocorrects to `freeze_time`' do
          expect(autocorrect_source('Timecop.freeze')).to(eq('freeze_time'))
        end
      end

      context 'with arguments' do
        it 'adds an offense' do
          expect_offense(<<~RUBY)
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
          expect_offense(<<~RUBY)
            Timecop.freeze { }
            ^^^^^^^^^^^^^^ Use `freeze_time` instead of `Timecop.freeze`
          RUBY
        end

        it 'autocorrects to `freeze_time`' do
          expect(autocorrect_source('Timecop.freeze { }')).to(eq('freeze_time { }'))
        end
      end

      context 'with arguments' do
        it 'adds an offense' do
          expect_offense(<<~RUBY)
            Timecop.freeze(123) { }
            ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.freeze`
          RUBY
        end

        # FIXME: Is this how NOT autocorrecting something should be tested?
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
        expect_offense(<<~RUBY)
          Timecop.return
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY
      end

      it 'autocorrects to `travel_back`' do
        expect(autocorrect_source('Timecop.return')).to(eq('travel_back'))
      end
    end

    context 'with a block' do
      it 'adds an offense' do
        expect_offense(<<~RUBY)
          Timecop.return { }
          ^^^^^^^^^^^^^^ Use `travel_back` instead of `Timecop.return`
        RUBY
      end

      it 'autocorrects to `travel_back`' do
        expect(autocorrect_source('Timecop.return { }')).to(eq('travel_back { }'))
      end
    end
  end

  describe 'Timecop.travel' do
    it 'adds an offense' do
      expect_offense(<<~RUBY)
        Timecop.travel(123) { }
        ^^^^^^^^^^^^^^^^^^^ Use `travel` or `travel_to` instead of `Timecop.travel`. If you need time to keep flowing, simulate it by travelling again.
      RUBY
    end
  end

  describe 'Timecop.*' do
    it 'adds an offense' do
      expect_offense(<<~RUBY)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end

  describe 'Timecop' do
    it 'adds an offense' do
      expect_offense(<<~RUBY)
        Timecop.foo
        ^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end

  describe '::Timecop' do
    it 'adds an offense' do
      expect_offense(<<~RUBY)
        ::Timecop.foo
        ^^^^^^^^^ Use `ActiveSupport::Testing::TimeHelpers` instead of `Timecop`
      RUBY
    end
  end
end
