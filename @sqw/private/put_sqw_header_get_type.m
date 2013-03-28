function no_inst_and_sample = put_sqw_header_get_type (header)
% Determines if the header contains a non-empty instument or sample field for one or more entries
%
%   >> no_inst_and_sample = put_sqw_header_get_type (header)
%
% Input:
% ------
%   header              header block (structure or cell array of structures)
%
% Output:
% -------
%   no_inst_and_sample  Logical scalar:
%                        true: if there are no instument and sample fields
%                              for any of the headers, or are empty if present
%                       false: otherwise

if iscell(header)
    for i=1:numel(header)
        if (isfield(header{i},'instrument') && ~isequal(header{i}.instrument,struct)) ||...
                (isfield(header{i},'sample') && ~isequal(header{i}.sample,struct))
            no_inst_and_sample=false;
            return
        end
    end
    no_inst_and_sample=true;
else
    if (isfield(header,'instrument') && ~isequal(header.instrument,struct)) ||...
            (isfield(header,'sample') && ~isequal(header.sample,struct))
        no_inst_and_sample=false;
    else
        no_inst_and_sample=true;
    end
end
