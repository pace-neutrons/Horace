function obj = check_and_set_labels_(obj,val)
% Verify and set up projaxis labels if validation is successful.
% throws invalid argument if not
if iscell(val) && numel(val) == 4
    if ~all(cellfun(@is_string,val,'UniformOutput',true))
        error('PROJAXES:invalid_argument',...
            'all labels has to be strings')
    end
    if size(val,1) == 4
        obj.labels_ = val';
    else
        obj.labels_ = val;
    end
else
    error('PROJAXES:invalid_argument',...
        ['a label should be a 4-element cellarray of strings or '...
        'single string, assighned to a particular label e.g. '...
        'proj.lab{3} = ''Q_x'''])
end

