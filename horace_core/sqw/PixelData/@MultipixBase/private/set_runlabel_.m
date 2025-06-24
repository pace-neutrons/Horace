function obj = set_runlabel_(obj,val)
%SET_RUNLABEL_  check and set value for runlabel(run_id) property
% 
% Acceptable values may be:
% 1) string containing 'nochange' or 'fileno' keys. Any other strings are not
%    acceptable. 
% "nochage" -- means that runlabels present in input pixels data do not
%              change
% "fileno"  -- runlables present in input pixels data change to the number
%              of the file (dataset) in the list of input datasets(files)
%              used by the class
% 2) array of numbers, with numel equal to the number of input
%    datasets(files) 
%              in this case, run_id-s of input datasets will be changed to
%              the numbers provided in this array.
% 

if istext(val)
    if ~any(strcmpi(val, {'nochange', 'fileno'}))
        error('HORACE:MultipxBase:invalid_argument',...
            'Invalid string value "%s" for run_label. Can be only "nochange" or "fileno"',...
            val)
    end
    obj.run_label_ = val;
elseif (isnumeric(val) && numel(val)==obj.nfiles)
    obj.run_label_ = val(:)';
else
    error('HORACE:MultipxBase:invalid_argument',...
        ['Invalid value for run_label. Array of run_id-s should be either specific string' ...
        'or array of unique numbers, providing run_id for each contributing file'])
end
