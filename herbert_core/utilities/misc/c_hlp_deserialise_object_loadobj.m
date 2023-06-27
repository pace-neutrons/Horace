function v = c_hlp_deserialize_object_loadobj(class_name, contents)
    v = eval([class_name, '.loadobj(contents)']);
end
