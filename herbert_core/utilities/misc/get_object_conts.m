function conts = get_object_conts(v)
% Helper  method used by mex-code to serialize object
% by converting it into a structure or whatever is optimal for this object.
%
% An objects need special treatment in C++
%
%
if isa(v, 'serializable')
    % the mentod of serializable class converts to structure both objects
    % and object arrays as one operation
    conts = shellow_struc(v);
else
    try
        % try to use the saveobj method first to get the contents
        conts = arrayfun(@saveobj, v);
    catch
        conts = arrayfun(@struct, v);
    end
    if ~(isstruct(conts) || iscell(conts) || isnumeric(conts) || ischar(conts) || islogical(conts) || isa(conts,'function_handle'))
        % contents is still an object: turn into a struct now
        conts = struct(conts);
    end
end

