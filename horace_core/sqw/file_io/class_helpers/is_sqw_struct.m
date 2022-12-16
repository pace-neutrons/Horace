function is = is_sqw_struct(input)
% Check if input structure can be considered an sqw structure.
%
if ~isstruct(input)
    if isa(input,'binfile_v4_block_tester') % this is for testing new file format
        is = true;
    else
        is = false;
    end
    return
end
if ~isfield(input,{'main_header','header','detpar','data'})
    is = false;
else
    is = true;
end
