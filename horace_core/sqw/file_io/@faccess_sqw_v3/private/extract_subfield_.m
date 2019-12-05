function subf = extract_subfield_(header,fld_name)
% Extract the requested (instrument or sample) subfield from the header
%
%Usage:
%>> subf = extract_subfield_(header,fld_name, n_files)
% where:
% header   -- an element or array of sqw single file header format
% fld_name -- the name of the field to extract
% nfiles   -- number of elements in header.
%
%
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%

%
if iscell(header)
    ns = numel(header);
    subf = cell(1,ns);
    for i=1:ns
        subf{i} = extract_subfield_(header{i},fld_name);
    end
else
    if isfield(header(1),fld_name)
        subf = header(1).(fld_name);
        nelem = numel(header);
        subf = repmat(subf,1,nelem );
        for i=2:nelem
            subf(i) = header(i).(fld_name);
        end
    else
        subf = struct([]);
    end
end