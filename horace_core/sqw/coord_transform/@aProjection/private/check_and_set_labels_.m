function obj = check_and_set_labels_(obj,val)
% Verify and set up aProjection labels if validation is successful.
% throws invalid argument if not
if iscell(val) && numel(val) == 4
    if ~all(cellfun(@is_string,val,'UniformOutput',true))
        error('HORACE:aProjection:invalid_argument',...
            'all labels has to be strings')
    end
    obj.label_ = val(:)';
else
    error('HORACE:aProjection:invalid_argument',...
        ['a label should be a 4-element cellarray of strings or '...
        'single string, assigned to a particular label e.g. '...
        'proj.label{3} = ''Q_x'' Actually it is: %s'],...
        disp2str(val))
end

