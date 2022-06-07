function val = check_and_get_combo_vec_(obj,name)
% verify and obtain the value of the vector, which may depend on other
% vectors
if obj.isvalid_
    val = obj.([name,'_']);
else
    [ok,mess,obj] = check_combo_arg_(obj);
    if ok
        val = obj.([name,'_']);
    else
        val = mess;
    end
end
