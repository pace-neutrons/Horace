function [f,added] = get_labels_to_struct (fid, f_in)
% Reads label information from an open file with file identifier fid, or from a cell array.
%
%   >> struc = get_labels_to_struct (input)
%   >> [struc,added] = get_labels_to_struct (input, struc_in)
%
% Input:
% ------
%   input       fid of an open file, cell array of strings, or character array
%   struc_in    (optional) input structure to which the new field will be appended
%
% Output:
% -------
%   struc       output structure; if f_in not given, then f=[] if nothing read
%   added       Logical flag: indicates if information was added to the input structure f_in
%
%
% Label information that is read has form:
%   lhs_1 = rhs_1
%   lhs_2 = rhs_2
%       :    :
%
% The label structure f is created with fields f.lhs_1 = rhs_1; f.lhs_2 = rhs_2 etc
% where the fields are created as character strings, or if the same left hand side appears more
% than once, as a cell array of character strings.
%
% If the lhs is not a valid variable name, then the line is ignored.


% T.G.Perring 5 Jan 2005: Created, based on label-reading code in mslice function LOAD_CUT (au. R.Coldea)
%               May 2011: Renamed from read_labels for consistency with other functions

if ischar(fid) && numel(size(fid))~=2
    error('Character array must be two-dimensional only')
else
    if iscellstr(fid)
        nline=numel(fid);
    else
        nline=size(fid,1);
    end
end

if nargin==1
    f = [];
    added=false;
elseif nargin==2 && isstruct(f_in)
    f = f_in;
    added=false;
else
    error('Can only add fields to a structure')

end

t = '';
icount = 0;
while (ischar(t))
    % analyse line
    pos=strfind(t,'=');
    if ~isempty(pos)
        field=t(1:pos(1)-1);
        field=field(~isspace(field));	% extract field name
        value=t(pos(1)+1:length(t));
        value=strtrim(value);	% extract string value
        if isvarname(field)
            if ~isfield(f,field)	% new field
                f.(field) = value;
                added=true;
            else                    % field already exists
                temp = f.(field);
                if isempty(temp)
                    f.(field) = value;
                    added=true;
                elseif ischar(temp)		% make into a cell of strings
                    f.(field) = {temp value};
                    added=true;
                elseif iscell(temp)
                    temp{length(temp)+1}=value;
                    f.(field) = temp;
                    added=true;
                end
            end
        end
    end
    % get next line
    if isnumeric(fid)
        t=fgetl(fid);
    elseif iscellstr(fid)||ischar(fid)
        if icount<nline
            icount = icount + 1;
            if iscellstr(fid)
                t = fid{icount};
            else
                t = fid(icount,:);
            end
        else
            t = -1;
        end
    else
        t = -1;
    end
end

end
