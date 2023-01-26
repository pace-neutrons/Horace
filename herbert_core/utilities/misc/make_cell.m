function arg = make_cell(arg)
    if ~iscell(arg)
        arg = {arg};
    end
end
