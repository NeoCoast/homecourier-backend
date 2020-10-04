class OrderRequest < ApplicationRecord
    enum order_request_status: %i(waiting rejected accepted)
    belongs_to :order
    belongs_to :volunteer
end
