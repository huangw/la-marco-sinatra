require 'spec_helper'
require 'la_buffered_logger'

describe LaBufferedLogger do
  subject(:logger) { LaBufferedLogger.new }

  describe '#level' do
    it 'default to :debug' do
      expect(logger.level).to eq(:debug)
    end
  end

  describe '#level=' do
    it 'accepts Logger::CONSTANT' do
      logger.level = Logger::ERROR
      expect(logger.level).to eq(:error)
    end

    it 'accepts :symbol' do
      logger.level = :error
      expect(logger.level).to eq(:error)
    end

    it 'accepts string' do
      logger.level = 'Error'
      expect(logger.level).to eq(:error)
    end
  end

  describe '#<severity>' do
    it 'returns nil if higher severity level set' do
      logger.level = :error
      expect(logger.info('some thing')).to be_nil
      expect(logger.msgs).to be_empty
    end

    it 'returns non-nil if lower or equal severitylevel set' do
      logger.level = :info
      expect(logger.info('some thing')).to_not be_nil
      expect(logger.msgs.last['message']).to eq('some thing')
      expect(logger.msgs.last['severity']).to eq('info')
    end
  end

  describe '#flush!' do
    it 'save messages only if flush!' do
      3.times { logger.error('a message') }
      expect(logger.msgs.count).to eq(3)
      logger.flush!
      expect(logger.msgs.count).to eq(0)

      5.times { logger.info('an info message') }
      expect(logger.msgs.count).to eq(5)
      logger.flush!
      expect(logger.msgs.count).to eq(0)
    end

    it 'flash message every time if flush threshold equals 0' do
      logger.flush_threshold = 0
      logger.error('a message')
      expect(logger.msgs.count).to eq(0)

      logger.error('a message 2')
      expect(logger.msgs.count).to eq(0)
    end

    it 'saves every time threshold reaches' do
      logger.flush_threshold = 3

      6.times { logger.error('a message') }
      expect(logger.msgs.count).to eq(2)
    end
  end
end
