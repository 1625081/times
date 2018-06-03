json.extract! room, :id, :class_id, :mon, :tue, :wed, :thr, :fri, :created_at, :updated_at
json.url room_url(room, format: :json)