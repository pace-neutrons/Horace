function conts = get_object_conts(v)
    % Objects need special treatment in C++
    if any(strcmp(methods(v), 'serialize'))
            conts = arrayfun(@(x) (x.serialize()), v);
    elseif isa(v,'serializable')
        conts = struct(v);
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
end
