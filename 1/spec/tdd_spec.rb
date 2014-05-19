require 'spec_helper'

def movie_factory(price_code = Movie::PRICE_CODES[rand(2)])
  Movie.new("#{Time.now}_title", price_code)
end

def rental_factory(movie = nil, days = rand(10))
  Rental.new(movie || movie_factory, days)
end

def customer_factory
  Customer.new("#{Time.now}_name")
end

describe Customer do
  subject{ customer_factory }

  describe '#add_rental' do
    it 'adds rental to rentals' do
      rental = rental_factory
      subject.add_rental rental
      expect(subject.rentals).to include(rental)
    end
  end
end

describe BillingFormatter::PlainText do
  subject{ described_class.new data }

  describe '#print' do
    let(:name){ 'asdad' }
    let(:amount){ 12 }
    let(:points){ 11111 }
    let(:data){ OpenStruct.new(name: name, amount: amount, points: points)}
    it 'formats text in proper way' do
      expected = "Rental Record for #{name}\nAmount owed is #{amount}\nYou earned #{points} frequent renter points"
      expect(subject.print).to eq expected
    end
  end
end

describe BillingFormatter do
  subject{ described_class.new(customer)}
  let(:days){ 10 }
  let(:rental){ rental_factory movie, days}
  let(:customer){ customer_factory }
  let(:movie){ movie_factory Movie::NEW_RELEASE }
  
  before{ customer.add_rental rental}

  describe '#statement' do
    it 'calls pattern class' do
      formatter = double
      result = '123123'
      expect(subject.pattern).to receive(:new).and_return(formatter)
      expect(formatter).to receive(:print).and_return(result)
      expect(subject.statement).to eq(result)
    end
  end

  describe 'calculation methods' do
    context 'for new release movie' do
      let(:movie){ movie_factory Movie::NEW_RELEASE }

      it 'calculates proper owed amount' do
        expect(subject.owed_amount).to eq(30)
      end
      it{ expect(subject.frequent_points).to eq(2)}
    end

    context 'for children movies' do
      let(:movie){ movie_factory Movie::CHILDRENS }

      it 'calculates proper owed amount' do
        expect(subject.owed_amount).to eq(12.0)
      end

      it{ expect(subject.frequent_points).to eq(1)}

    end

    context 'for regular movies' do
      let(:movie){ movie_factory Movie::REGULAR}

      it 'calculates proper owed amount' do
        expect(subject.owed_amount).to eq(14.0)
      end

      it{ expect(subject.frequent_points).to eq(1)}

    end
  end
end