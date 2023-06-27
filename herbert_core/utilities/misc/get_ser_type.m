function type = get_ser_type(v)
    % Objects need special treatment in C++
    if ismethod(v, 'serialize')
            % The object has serialized itself
            type = uint8(0);
    else
        try
            % try to use the saveobj method first to get the contents
            saveobj v(1);
            % The object is serialized through the saveobj method
            type = uint8(1);
        catch
            % The object is serialized through struct directly
            type = uint8(2);
        end
    end
end
