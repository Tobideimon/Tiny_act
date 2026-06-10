require "test_helper"

class FurnitureTest < ActiveSupport::TestCase
  test "belongs to an interest" do
    furniture = Furniture.new(
      name: "Desk",
      image_url: "furnitures/Bureau.png",
      width: 1,
      height: 1,
      required_xp: 20
    )

    assert_not furniture.valid?
    assert_includes furniture.errors[:interest], "must exist"
  end
end
