function inst_or_sample = put_sqw_header_get_type (header)
% Determines if the header contains a non-empty instument or sample field for one or more entries
%
%   >> no_inst_and_sample = put_sqw_header_get_type (header)
%
% Input:
% ------
%   header              Header block (structure or cell array of structures)
%
% Output:
% -------
%   inst_and_sample     Logical scalar:
%                        true: If there are no instument and sample fields
%                              for any of the headers, or if they have the
%                              default 'empty' status i.e. ==struct (this is
%                              a 1x1 structure with no fields).
%                       false: Otherwise


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if iscell(header)
    for i=1:numel(header)
        if (isfield(header{i},'instrument') && ~isequal(header{i}.instrument,struct)) ||...
                (isfield(header{i},'sample') && ~isequal(header{i}.sample,struct))
            inst_or_sample=true;
            return
        end
    end
    inst_or_sample=false;
else
    if (isfield(header,'instrument') && ~isequal(header.instrument,struct)) ||...
            (isfield(header,'sample') && ~isequal(header.sample,struct))
        inst_or_sample=true;
    else
        inst_or_sample=false;
    end
end
