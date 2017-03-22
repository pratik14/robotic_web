file = File.read('./public/keywords.json')
hash = JSON.parse(file)

Keyword.destroy_all
hash.each do |key, value|
  arguments = value['args'].to_s.split(',').collect(&:strip)
  Keyword.create!(name: value['name'], arguments: arguments, documentation: value['doc'])
end

User.create(email: 'b@b.com', password: 'josh12345', password_confirmation: 'josh12345').confirm!
