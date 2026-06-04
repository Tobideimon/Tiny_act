
puts "Cleaning furnitures..."

RoomFurniture.destroy_all
Furniture.destroy_all

puts "Creating furnitures..."

Furniture.create!(
  name: "Punching Ball",
  image_url: "furnitures/punching_ball.png",

  # Occupation au sol
  width: 1,
  height: 1

  # Le PNG sera simplement plus haut visuellement
)

Furniture.create!(
  name: "Sport Mat",
  image_url: "furnitures/sport_mat.png",

  # 2 cases de large
  width: 2,
  height: 1
)

Furniture.create!(
  name: "Books",
  image_url: "furnitures/books.png",

  # 1 cases de large
  width: 1,
  height: 1
)

Furniture.create!(
  name: "pool",
  image_url: "furnitures/pool.png",

  # 1 cases de large
  width: 1,
  height: 1
)

Furniture.create!(
  name: "escalade",
  image_url: "furnitures/Escalade.png",

  # 1 cases de large
  width: 2,
  height: 1
)

Furniture.create!(
  name: "orangechair",
  image_url: "furnitures/chair.png",

  # 1 cases de large
  width: 1,
  height: 1
)

Furniture.create!(
  name: "Jasky",
  image_url: "furnitures/jasky.gif",

  # Occupation au sol
  width: 1,
  height: 1

  # Le PNG sera simplement plus haut visuellement
)

puts "#{Furniture.count} furnitures created!"
