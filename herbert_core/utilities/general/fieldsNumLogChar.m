function status = fieldsNumLogChar (A, opt)
% Determine if the fields or properties are ok for sortStruct, sortObj or sortObjIndep
%
%   >> status = fieldsNumLogChar (A)
%   >> status = fieldsNumLogChar (A, 'public')      % equivalent to the above
%   >> status = fieldsNumLogChar (A, 'independent') % object independent properties
%
% Input:
% ------
%   A       Struct array or object array to be sorted
%           The properties must be must be numeric arrays, logical arrays,
%          or character arrays to be suitable for sorting with sortStruct,
%          sortObj or sortObjIndep or the mirror unique sorts function
%          uniqueStruct, uniqueObj or uniqueObjIndep
%
% Optional keywords:
%  'public'         Keep public properties (independent and dependent)
%                   More specifically, it calls an object method called 
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%
%  'independent'    Keep independent properties only (hidden, protected and
%                  public)
%                   More specifically, it calls an object method called 
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.
%
% Output:
% -------
%   status  True or false

% Developers: Make sure that any changes to sortStruct, sortObj or
% sortObjIndep are consistent with this function.


public = true;
if exist('opt','var')
    if is_string(opt)
        if strncmpi(opt,'independent',numel(opt))
            public = false;
        elseif ~strncmpi(opt,'public',numel(opt))
            error('Invalid optional argument')
        end
    else
        error('Invalid optional argument')
    end
end

if isstruct(A)
    status = checkfields(A);
elseif isobject(A)
    if public
        status = checkfields(structPublic(A));
    else
        status = checkfields(structIndep(A));
    end
end

%------------------------------------------------------------------------------
function status = checkfields(A)
% Check classes of fieldnames are suitable for use with sortStruct, sortObj, sortObjIndep

nams = fieldnames(A);
for i=1:length(nams)
    val = A.(nams{i});
    if ~( isnumeric(val) || islogical(val) || ischar(val) )
        status = false;
        return
    end
end
status = true;
