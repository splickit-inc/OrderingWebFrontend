runs = 100
times = []
merchant = Merchant.find(104250)
runs.times do
  before = Time.now
  merchant = Merchant.find(104250)
  total = Time.now - before
  puts "finding and loading JM took #{total} seconds"
  times.push total
end

average = (times.reduce(:+)) / runs
puts "Average time: #{average}"