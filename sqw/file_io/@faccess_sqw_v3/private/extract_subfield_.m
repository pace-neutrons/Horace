function subf = extract_subfield_(header,fld_name, n_files)
% Extract the requested (instrument or sample) subfield from the header
%Usage:
%>> subf = extract_subfield_(header,fld_name, n_files)
% where:
% header   -- an element or array of sqw single file header format
% fld_name -- the name of the field to extract
% nfiles   -- number of elements in header. 
% 
% 
%
if isfield(header(1),fld_name)
    subf = header(1).(fld_name);
    subf = repmat(subf,1,n_files);
    for i=2:n_files
        subf(i) = header(i).(fld_name);
    end
else
    subf = struct([]);
end
