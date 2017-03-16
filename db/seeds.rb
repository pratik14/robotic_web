# file = File.read('./public/keywords.json')
file = File.read('./public/newKeyword.json')
hash = JSON.parse(file)

Keyword.destroy_all
hash.each do |key, value|
  Keyword.create!(name: value['name'], arguments: value['args'].to_s.split(',').collect(&:strip), documentation: value['doc'])
end
