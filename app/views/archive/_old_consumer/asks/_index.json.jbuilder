# json.array! @asks, partial: 'asks/ask', as: :ask

json.asks do
  json.array! @asks do |ask|
    json.ask do
      json.id ask.id
      json.date ask.created_at
      json.sum ask.sum
      json.delivery_cost ask.delivery_cost
      json.total ask.total
      json.status ask.status
      json.link producer_ask_path(ask.id)
      # json.orders do
      #   json.array! ask.orders do |order|
      #     json.order do
      #       json.id order.id
      #       json.order
      #     end
      #   end
      # end
    end
  end
end