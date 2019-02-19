# frozen_string_literal: true

RSpec.describe Rubocop::Cop::Rails::ActiveSupportConcern do
  subject(:cop) { described_class.new }

  it 'detects pointless concern extension' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ BAD
      end
    RUBY
  end

  it 'is fine if you use all features' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        included { foo }

        module ClassMethods
          def foo
          end
        end

        class_methods do
          def foo
          end
        end
      end
    RUBY
  end

  it 'is fine if you use all features' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        module ClassMethods
          def foo
          end
        end
      end
    RUBY
  end

  it 'is fine if you use all features' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        included { foo }

        module ClassMethods
          def foo
          end
        end
      end
    RUBY
  end

  it 'is fine if you use all features' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        included { foo }

        class_methods do
          def foo
          end
        end
      end
    RUBY
  end

  it 'is fine if you call `included` with a block' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        included { foo }
      end
    RUBY
  end

  it 'is fine if you call `class_methods` with a block' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        class_methods { foo }
      end
    RUBY
  end

  it 'is fine if you call `class_methods` with a block' do
    expect_no_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        module ClassMethods
          def foo
          end
        end
      end
    RUBY
  end

  it 'blows up if you call included without a block' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        included
        ^^^^^^^^ BAD
      end
    RUBY
  end

  it 'blows up if you call class_methods without a block' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        class_methods
        ^^^^^^^^^^^^^ BAD
      end
    RUBY
  end

  it 'blows up if you define an empty ClassMethods' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        module ClassMethods
        ^^^^^^^^^^^^^^^^^^^ BAD
        end
      end
    RUBY
  end

  it 'blows up if you define an empty ClassMethods' do
    expect_offense(<<-RUBY.strip_indent)
      module Test
        extend ActiveSupport::Concern

        ClassMethods = Module.new
        ^^^^^^^^^^^^^^^^^^^^^^^^^ BAD
        end
      end
    RUBY
  end

  it 'detects pointless concern inheritance' do
    # This is just invalid, but we can detect it anyway.
    expect_offense(<<-RUBY.strip_indent)
      module Test < ActiveSupport::Concern
                  ^^^^^^^^^^^^^^^^^^^^^^^^ BAD
      end
    RUBY
  end
end
