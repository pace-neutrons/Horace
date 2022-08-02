<<<<<<< HEAD
<<<<<<< HEAD
function out_file = get_bm_name()
    function_stack = dbstack;
    name = function_stack(2).name;
    out_file = [name, '.csv'];
=======
function [out_file, nDims, dataType, dataNum, nProcs] = get_bm_name()
    function_stack = dbstack;
    name = function_stack(2).name;
    out_file = [name, '.csv'];
    x = regexp(name, 'test_bm_([a-z_]+)_(\d)D_(small|medium|large)Data_(small|medium|large)(?:Number|Energy)_(\d+)procs', 'tokens');
    [function_name, nDims, dataType, dataNum, nProcs] = x{1}{:};
>>>>>>> 89ccf4ee9 (Replace duplicated code (#833))
=======
function out_file = get_bm_name()
    function_stack = dbstack;
    name = function_stack(2).name;
    out_file = [name, '.csv'];
>>>>>>> 8d4db5de5 (updating gen_data functions)
end
