function [v,nbytes] = c_hlp_deserialize_object_self(class_name, m)
    instance = feval(class_name);
    [v, nbytes] = instance.deserialize(m, 0);
end
