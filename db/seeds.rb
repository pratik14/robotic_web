file = File.read('./public/keywords.json')
hash = JSON.parse(file)

Keyword.destroy_all
hash.each do |key, value|
  Keyword.create!(name: value['name'], arguments: value['args'], documentation: value['doc'])
end
