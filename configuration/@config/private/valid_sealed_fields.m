function [ok,mess]=valid_sealed_fields(sealed_fields,namlist)
% Check that a variable is a valid 'sealed_fields' list for a structure:
%   - is empty
%   - a single character string matching one of the fields of the structure
%   - is a cellstr with one empty string
%   - is a cellstr of fields of the structure
%
%   Assumes that namlist is a cellarray of field names

ok=true;
mess='';
if isempty(sealed_fields)
    return
elseif ischar(sealed_fields) && size(sealed_fields,1)==1
    return
elseif iscellstr(sealed_fields)
    if numel(sealed_fields)==1 && isempty(sealed_fields{1})
        return
    else
        isstr=false(size(sealed_fields));
        for i=1:numel(sealed_fields)
            isstr(i)=~isempty(sealed_fields{i}) && size(sealed_fields{i},1)==1;
        end
        if ~all(isstr) || ~all(ismember(sealed_fields,namlist))
            ok=false;
            mess=['''sealed_fields'' can only be a cell array of valid field names for ',...
                'the configuration class, a cell array with one empty string, or an empty parameter'];
            return
        end
    end
else
    ok=false;
    mess=['''sealed_fields'' can only be a cell array of valid field names for ',...
        'the configuration class, a cell array with one empty string, or an empty parameter'];
    return
end
