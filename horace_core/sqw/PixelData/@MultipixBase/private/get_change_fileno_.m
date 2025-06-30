function is = get_change_fileno_(obj)
%GET_CHANGE_FILENO  chceck if pixel id for each pixel from contributing
% files should be changed.

if ischar(obj.run_label)
    if strcmpi(obj.run_label,'nochange')
        is=false;
    elseif strncmpi(obj.run_label,'filen',5)
        is = true;
    end
elseif isnumeric(obj.run_label)
    is=true;
end
