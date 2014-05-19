class Movie
  REGULAR = :regular
  NEW_RELEASE = :new_release
  CHILDRENS = :childrens
  PRICE_CODES = [REGULAR, NEW_RELEASE, CHILDRENS]
   
  attr_reader :title
  attr_accessor :price_code
   
  def initialize(title, price_code)
    @title, @price_code = title, price_code
  end
 end 


class Rental
  attr_reader :movie, :days_rented 
  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end

  def amount
    send "run_for_#{movie.price_code.downcase}"
  end

  private

  def run_for_regular
    this_amount = 2
    this_amount += (days_rented - 2) * 1.5 if days_rented > 2
    this_amount
  end

  def run_for_new_release
    days_rented * 3
  end

  def run_for_childrens
    this_amount = 1.5
    this_amount += (days_rented - 3) * 1.5 if days_rented > 3
    this_amount
  end
end 


class Customer
  attr_reader :name, :rentals
 
  def initialize(name)
    @name = name
    @rentals = []
  end
 
  def add_rental(arg)
    @rentals << arg
  end
end

class BillingFormatter
  attr_reader :pattern

  def initialize(customer, pattern = BillingFormatter::PlainText)
    @rentals = customer.rentals
    @name = customer.name
  end

  def statement
    data = OpenStruct.new(name: @name, amount: amount, points: points)
    pattern.new(data).print
  end

  def amount
    owed_amount
  end
  def points
    frequent_points
  end

  def owed_amount
    RentalsAmountCalculator.new(@rentals).run
    end

  def frequent_points
    FrequentPointsCalculator.new(@rentals).run
  end
end

class FrequentPointsCalculator
  def initialize(rentals)
    @rentals = rentals
  end

  def run
    frequent_renter_points = 0
    @rentals.each do |element|
      frequent_renter_points += 1
      if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1 
        frequent_renter_points += 1
      end
    end
    frequent_renter_points
  end
end

class RentalsAmountCalculator
  def initialize(rentals)
    @rentals = rentals
  end

  def run
    @rentals.inject(0){ |sum, n| sum += n.amount}
  end
end

class BillingFormatter::PlainText
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def print
    "Rental Record for #{data.name}\nAmount owed is #{data.amount}\nYou earned #{data.points} frequent renter points"
  end
end