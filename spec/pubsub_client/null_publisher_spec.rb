# frozen_string_literal: true

class PubsubClient
  RSpec.describe NullPublisher do
    subject { described_class.new }

    describe '.publish' do
      context 'when calling methods from the real contract' do
        it 'responds to succeeded?' do
          yielded_result = nil
          subject.publish('foo') do |result|
            yielded_result = result
          end
          expect(yielded_result.succeeded?).to eq(true)
        end

        it 'responds to error' do
          yielded_result = nil
          subject.publish('foo') do |result|
            yielded_result = result
          end
          expect(yielded_result.error).to be_nil
        end
      end
    end
  end
end
