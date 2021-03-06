module TrainingsHelper
  def link_to_add_training_segment(name, f, association) 
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.simple_fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', id: "add_training_segment_btn", class: "btn btn-success add_training_segment_btn", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
