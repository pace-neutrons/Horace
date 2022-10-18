function out_file = get_bm_name()
    function_stack = dbstack;
    name = function_stack(2).name;
    out_file = [name, '.csv'];
end
