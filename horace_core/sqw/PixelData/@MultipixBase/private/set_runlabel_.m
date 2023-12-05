function obj = set_runlabel_(obj,val)
%SET_RUNLABEL_  check and set value for runlabel property


if ischar(val)
    if ~(strcmpi(val,'nochange') || strcmpi(val,'fileno'))
        error('HORACE:pixfile_combine_info:invalid_argument',...
            'Invalid string value "%s" for run_label. Can be only "nochange" or "fileno"',...
            val)
    end
    obj.run_label_ = val;
elseif (isnumeric(val) && numel(val)==obj.nfiles)
    obj.run_label_ = val(:)';
else
    error('HORACE:pixfile_combine_info:invalid_argument',...
        ['Invalid value for run_label. Array of run_id-s should be either specific string' ...
        'or array of unique numbers, providing run_id for each contributing file'])
end
