json.products_count !@products.empty? ? @products.first.category.products.size : 0
json.products do
  json.array! @products do |product|
    json.product do
      json.link product_path product.id
      json.id product.id
      json.title product.name
      json.measures product.measures
      json.price product.price
      json.category_id product.category.id ? product.category.id : ""
      json.producer_id product.producer.id ? product.producer.id : ""
      json.rank product.rank
      json.image product.image.attached? ? url_for(product.image) : ""
    end
  end
end

json.pagination @pagination