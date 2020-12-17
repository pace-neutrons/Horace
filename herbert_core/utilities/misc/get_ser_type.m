function type = get_ser_type(v)
    % Objects need special treatment in C++
    if any(strcmp(methods(v), 'serialize'))
            type = uint8(0);
    else
        try
            % try to use the saveobj method first to get the contents
            saveobj v(1);
            type = uint8(1);
        catch
            type = uint8(2);
        end
    end
end
