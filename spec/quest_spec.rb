require 'spec_helper'

Quest = TallyGem::Quest

describe Quest do
  context 'display_name' do
    context 'given whitespace'do
      before { subject.display_name = '    ' }
      it 'is used as-is' do
        expect(subject.display_name).to eq('    ')
      end
    end

    context 'given a normal name' do
      before { subject.display_name = 'My Quest' }
      it 'is used as-is' do
        expect(subject.display_name).to eq('My Quest')
      end
    end

    context 'given a unicode name' do
      before { subject.display_name = "My\u200bQuest" }
      it 'cleans it' do
        expect(subject.display_name).to eq('MyQuest')
      end
    end

    context 'given a name with trim' do
      before { subject.display_name = ' My Quest  ' }
      it 'retains trim' do
        expect(subject.display_name).to eq(' My Quest  ')
      end
    end

    context 'given nil' do
      before { subject.display_name = 'My Quest'; subject.display_name = nil }
      it 'resets' do
        expect(subject.display_name).to eq('fake-thread.00000')
      end
    end

    context 'given an empty string' do
      before { subject.display_name = 'My Quest'; subject.display_name = nil }
      it 'resets' do
        expect(subject.display_name).to eq('fake-thread.00000')
      end
    end
  end

  context 'start_post' do
    it 'rejects zero' do
      expect{ subject.start_post = 0 }.to raise_error(ArgumentError)
    end

    it 'rejects negative numbers' do
      expect{ subject.start_post = -1 }.to raise_error(ArgumentError)
    end

    it 'accepts one' do
      expect{ subject.start_post = 1}.not_to raise_error
    end

    it 'accepts positive numebers' do
      expect{ subject.start_post = 45000 }.not_to raise_error
    end
  end

  context 'end_post' do
    it 'rejects negative numbers' do
      expect{ subject.end_post = -1 }.to raise_error(ArgumentError)
    end

    it 'accepts zero' do
      expect{ subject.end_post = 0 }.not_to raise_error
    end

    it 'accepts positive numbers' do
      expect{ subject.end_post = 1 }.not_to raise_error
    end
  end
end