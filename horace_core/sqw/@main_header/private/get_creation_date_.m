function cd = get_creation_date_(obj)
% Retrieve file creation date either from stored value, or
% from system file date.

if obj.no_cr_date_known_ % assume that creation date is unknown and
    % will be set as creation date of the file later and
    % explicitly.
    % Return eher file date if file exist or
    % actual date, if it does not
    file = fullfile(obj.filepath,obj.filename);
    if ~isfile(file)
        dt = datetime("now");
    else
        finf= dir(file);
        dt = finf.date;
    end
else
    dt = obj.creation_date_;
end
cd = obj.DT_out_transf_(dt);
