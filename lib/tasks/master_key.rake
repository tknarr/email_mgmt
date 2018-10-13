task :master_key => :environment do
    rng = Random.new
    s = rng.bytes(16).each_byte.map { |b| b.to_s 16 }.join
    puts s
end
