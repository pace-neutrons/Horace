function [S,ok,mess] = parse_set_internal (varargin)
% Check arguments are valid for set methods. Throws an error if not.
%
%   >> [S,ok,mess] = parse_set_internal (field1, val1, field2, val2, ...)
%   >> [S,ok,mess] = parse_set_internal (struct)
%   >> [S,ok,mess] = parse_set_internal (cellnam, cellval) % Cell arrays of field names and values
%   >> [S,ok,mess] = parse_set_internal (cellarray)        % Cell array has the form {field1,val1,field2,val2,...}
%
%
%
% Input:
% ------
%                   Configuration object in any of the forms
%
% Output:
% -------
%   S               Structure with the fields of configuration object, and with
%                   values updated according to the input arguments
%   ok              True if all ok, false otherwise
%
%   mess            Error message if not ok; ='' otherwise
% 
%
% EXAMPLES:
%   >> [S,ok,mess] = parse_set_internal (my_config,'a',10,'b','something')
%
%   >> [S,ok,mess] = parse_set_internal (my_config,'a',10,'b','something')
%
%   >> [S,ok,mess] = parse_set_internal (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% NOTE: For internal use only.

% $Revision: 313 $ ($Date: 2013-12-02 11:31:41 +0000 (Mon, 02 Dec 2013) $)

% Default return values
S=struct();
ok=true;
mess='';

narg = length(varargin);


if narg==1
    % Structure, cell array of field name/value pairs, or special option
    svar = varargin{1};
    if isstruct(svar)
        S = svar;
        return;
        
    elseif iscell(svar)
        if isempty(svar) 
            return
        end
        if rem(numel(svar),2)~=0
            ok=false; mess='Incomplete set of (fieldname,value) pairs given'; return
        end
        field_nams = svar{1:2:end};
        field_vals = svar{2:2:end};
        
        if numel(unique(field_nams))~=numel(field_nams)
            ok=false; mess='One or more name arguments are repeated'; return
        end           
    else
        ok=false; mess='Second parameter of two has to be a structure, a cell array, or the option ''defaults'''; return
    end

elseif narg==2 && iscell(varargin{1}) && iscell(varargin{2})
    % Cell array of field names and a cell array values
    field_nams = varargin{1}(:);
    field_vals = varargin{2}(:);
    if numel(field_nams)~=numel(field_vals)
        ok=false; mess='Numbers of field names and field values do not match'; return
    elseif ~valid_fieldnames(field_nams)
        ok=false; mess='Cell array of field names not all valid field names for a structure'; return
    elseif numel(unique(field_nams))~=numel(field_nams)
        ok=false; mess='One or more name arguments are repeated'; return
    end
    
else
    % Field name/value pairs
    if rem(narg,2)==0
        field_nams = varargin(1:2:narg);
        field_vals = varargin(2:2:narg);
        if numel(unique(field_nams))~=numel(field_nams)
            ok=false; mess='One or more name arguments are repeated'; return
        end
    else
        ok=false; mess='Incomplete set of (fieldname,value) pairs given'; return
    end
end

% Update fields in the structure
for i=1:numel(field_nams)
    S.(field_nams{i})=field_vals{i};
end
