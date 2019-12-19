function is = is_sqw_struct(input)
% Check if input structure can be considered an sqw structure.
%
if ~isstruct(input)
    is = false;
    return
end
if ~isfield(input,{'main_header','header','detpar','data'})
    is = false;
else
    is = true;
end
