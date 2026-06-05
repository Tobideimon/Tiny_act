
puts "Cleaning furnitures..."

RoomFurniture.destroy_all
Furniture.destroy_all

puts "Creating furnitures..."

sport = Interest.find_by(name: "Sport"),
culture = Interest.find_by(name: "Culture")

Furniture.create!(
  name: "Books",
  image_url: "furnitures/books.png",
  required_xp: 10,
  width: 1,
  height: 1,
  interest: culture
)

Furniture.create!(
  name: "escalade",
  image_url: "furnitures/Escalade.png",
  interest: sport,
  required_xp: 50,
  width: 2,
  height: 1
)

Furniture.create!(
  name: "orangechair",
  image_url: "furnitures/chair.png",
  interest: culture,
  required_xp: 5,
  width: 1,
  height: 1
)

Furniture.create!(
  name: "Punching Ball",
  image_url: "furnitures/punching_ball.png",
  width: 1,
  height: 1,
  interest: sport,
  required_xp: 30
)

Furniture.create!(
  name: "Sport Mat",
  image_url: "furnitures/sport_mat.png",
  width: 2,
  height: 1,
  interest: sport,
  required_xp: 5
)

puts "#{Furniture.count} furnitures created!"
