module Ambassadr
  class Services
    describe Response do

      let(:test) { {
        a: 1,
        b: { c: true }
      } }

      let(:response) { Response.new test }

      subject { response }

      it { should respond_to(:a) }

      it { should respond_to(:b) }

      specify { expect(subject.a).to eq 1 }

      specify { expect(subject.b.c).to be_truthy }

      describe 'an array response' do

        let(:array) { { stacks: [test] * 4 } }

        let(:array_response) { Response.new array }

        subject { array_response }

        it { should respond_to(:each) }

        specify { expect(subject.stacks.first.a).to eq 1 }

        specify { expect(subject.stacks.first.b.c).to be_truthy }

      end

    end
  end
end
