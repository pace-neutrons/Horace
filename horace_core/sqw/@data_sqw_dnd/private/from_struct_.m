function  obj = from_struct_(obj,input)
% set up sqw_dnd_data object from the input structure
%
%
flds = fieldnames(input);
if ~isfield(input,'version')
    for i=1:numel(flds )
        fldn = flds{i};
        if strcmp(fldn,'urange')
            fldn = 'img_range';
        end
        obj.(fldn) = input.(flds{i});
    end
elseif input.version == 1
    input = rmfield(input,'version');
    for i=1:numel(flds )
        obj.(flds{i}) = input.(flds{i});
    end
end

