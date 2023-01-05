function tm = get_creation_date(obj)
% Get the creation date of the current file
%
% extract code which gets creation date into separate
% function to allow overloading
file = obj.full_filename;
if is_file(file)
    finf= dir(file);
    tm = finf.date;
else
    tm = [];
end
