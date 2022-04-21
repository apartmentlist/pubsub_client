# frozen_string_literal: true

class PubsubClient
  RSpec.describe Publisher do
    subject(:publisher) { described_class.new(topic) }

    let(:topic) { instance_double(Google::Cloud::PubSub::Topic) }

    describe 'async publishing' do
      before do
        allow(topic)
          .to receive(:publish_async)
          .and_yield('the-result')
      end

      it 'publishes the message' do
        subject.publish('foo') { |_| }
        expect(topic).to have_received(:publish_async)
          .with('foo', {})
      end

      it 'supports attributes' do
        subject.publish('foo', bar: 'baz') { |_| }
        expect(topic).to have_received(:publish_async)
          .with('foo', {bar: 'baz'})
      end

      it 'yields the result to a block' do
        yielded_result = nil
        subject.publish('foo') do |result|
          yielded_result = result
        end
        expect(yielded_result).to eq('the-result')
      end
    end # describe

    describe 'synchronous publishing' do
      before do
        allow(topic).to receive(:publish)
      end

      it 'publishes the message' do
        subject.synchronous_publish('foo')
        expect(topic).to have_received(:publish)
          .with('foo', {})
      end

      it 'supports attributes' do
        subject.synchronous_publish('foo', bar: 'baz')
        expect(topic).to have_received(:publish)
          .with('foo', {bar: 'baz'})
      end
    end # describe
  end # Rspec
end
