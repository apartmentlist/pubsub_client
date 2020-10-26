# frozen_string_literal: true

module PubsubClient
  RSpec.describe Publisher do
    subject(:publisher) { described_class.new(topic) }

    let(:topic) { instance_double(Google::Cloud::PubSub::Topic) }

    before do
      allow(topic)
        .to receive(:publish_async)
        .and_yield('the-result')
    end

    it 'publishes the message asynchronously' do
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
  end
end
