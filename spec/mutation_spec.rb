# frozen_string_literal: true

# This demonstrates the problem with the spy syntax for RSpec mocks when
# combined with mutation.

class SomeObject

  # This method makes a call and then mutates one of the parameters
  # to the call.
  def mutating_method
    filename = 'blah' + '.txt'
    File.delete(filename)

    # This line runs after the spied on call but confuses the spy
    filename.gsub!('a', 'e')
  end
end

describe SomeObject do
  describe 'allowing message gets confused by mutation' do
    before do
      allow(File).to receive(:delete)
    end

    it 'deletes the file' do
      described_class.new.mutating_method

      # This is what actually happened:
      # expect(File).to have_received(:delete).with('blah.txt')

      # This is what it thinks happened:
      expect(File).to have_received(:delete).with('bleh.txt')
    end
  end


  describe 'expecting message is not confused' do
    before do
      expect(File).to receive(:delete).with('blah.txt')
      expect(File).not_to receive(:delete).with('bleh.txt')
    end

    it 'deletes the file' do
      described_class.new.mutating_method
    end
  end
end
