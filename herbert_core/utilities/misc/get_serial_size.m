function size = get_serial_size(v)
% Helper  method used by mex-code to get size ot the serializeble object
% by converting it into a structure or whatever is optimal for this object.
%
% An objects need special treatment in C++
%
%
if ismethod(v, 'serial_size')
    size = v.serial_size();
else
    try
        % try to use the saveobj method first to get the contents
        conts = arrayfun(@saveobj, v);
    catch
        conts = arrayfun(@struct, v);
    end
    size = serial_size(conts);
end

