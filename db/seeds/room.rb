puts "Creating furnitures..."

chair = Furniture.find_or_create_by!(name: "Chaise") do |f|
  f.image_url = "furnitures/chair.png"
  f.width = 1
  f.height = 1
end

table = Furniture.find_or_create_by!(name: "Table") do |f|
  f.image_url = "furnitures/table.png"
  f.width = 2
  f.height = 1
end

puts "Adding furnitures to rooms..."

User.find_each do |user|
  room = user.room || user.create_room!(width: 8, height: 8)

  room.room_furnitures.find_or_create_by!(
    furniture: chair,
    x: 2,
    y: 2
  ) do |item|
    item.z = 0
    item.rotation = 0
  end

  room.room_furnitures.find_or_create_by!(
    furniture: table,
    x: 4,
    y: 3
  ) do |item|
    item.z = 0
    item.rotation = 0
  end
end

puts "Done."
