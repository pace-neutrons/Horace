function cd = get_creation_date_(obj)
% Retrieve file creation date either from stored value, or
% from system file date.

if obj.creation_date_defined_
    dt = obj.creation_date_;
else % assume that creation date is unknown and
    % will be set as creation date of the file later and
    % explicitly.
    % Return either file date if file exist or
    % actual date, if it does not
    file = fullfile(obj.filepath,obj.filename);
    if ~isfile(file)
        dt = datetime("now");
    else
        finf= dir(file);
        dt = datetime(finf.date);
    end
end
cd = obj.DT_out_transf_(dt);
