function [ok,mess,sealed_fields_out]=valid_sealed_fields(sealed_fields,namlist)
% Check that a variable is valid as a list of sealed field names for a structure
%
%   >> [ok,mess]=valid_sealed_fields(sealed_fields,namlist)
%
% Input:
% ------
%   sealed_fields       List of field names that are sealed
%                       Valid input is:
%                       - empty argument of any type (interpreted as no sealed fields)
%                       - cellstr with one element only and which is empty (interpreted as no sealed fields)
%                       - single character string matching one of the fields of the structure
%                       - cellstr of fields of the structure
%
%   namlist             Cell array of valid field names for a structure (i.e.
%                       valid names, and unique)
%
% Output:
% -------
%   ok                  =true if valid input
%   mess                Error message if not ok; empty otherwise
%   sealed_fields_out   Converted to standard format i.e. row cellstr of field names
%                      (excluding the name 'sealed_fields', which is always sealed)
%                       Set to {} if not ok.

% $Revision$ ($Date$)

ok=true;
mess='';

if isempty(sealed_fields) || (iscell(sealed_fields) && numel(sealed_fields)==1 && isempty(sealed_fields{1}))
    % Return default if sealed_fields is empty or is a cell with one, empty, element
    sealed_fields_out={};
    return
elseif ischar(sealed_fields) && size(sealed_fields,1)==1
    % Single character string
    sealed_fields_out={sealed_fields};
else
    % Check is a cell array of non-empty character strings
    allstr=false;
    if iscellstr(sealed_fields)
        isstr=false(size(sealed_fields));
        for i=1:numel(sealed_fields)
            isstr(i)=~isempty(sealed_fields{i}) && size(sealed_fields{i},1)==1;
        end
        allstr=all(isstr(:));
    end
    if ~allstr
        ok=false;
        mess=['''sealed_fields'' can only be a valid field name or cell array of valid field names for ',...
            'the configuration class, unless it is empty parameter (meaning that there are no sealed fields)'];
        sealed_fields_out={};
        return
    end
    sealed_fields_out=sealed_fields(:);     % ensure is a column vector
end

% Now check that the character strings are a list of unique members of the list of fields
if numel(unique(sealed_fields_out))==numel(sealed_fields_out)
    if all(ismember(sealed_fields_out,namlist))
        ind=strcmp('sealed_fields',sealed_fields_out);
        if any(ind)     % Remove sealed_fields from the final field
            sealed_fields_out=sealed_fields_out(~ind);
        end
    else
        ok=false;
        mess='The sealed fields must all be valid field names for the configuration class';
        sealed_fields_out={};
    end
else
    ok=false;
    mess='The list of sealed field names must not contain repeated entries';
    sealed_fields_out={};
end

% Make sealed fields list a row vector
sealed_fields_out=sealed_fields_out';
