function s = structArrIndep(obj)
% Return the independent properties of an object array as a structure array
%
%   >> s = structArrIndep(obj)
%
% Has the same behaviour as the Matlab intrinsic struct in that:
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
%
% However, differs in the behaviour if an object array:
% - If the object is non-empty array, returns a structure array of the same
%   size. This is different to the intrinsic Matlab, which returns a scalar
%   structure from the first element in the array of objects
%
%
% See also structArr, structArrPublic, struct, structPublic, structIndep


% Get warning state that we must turn of if obj is a new style object array
% If not done, then the call to Matlab intrinsic struct will throw a warning
state = warning('query','MATLAB:structOnObject');
reset_warning = onCleanup(@()warning(state));
warning('off','MATLAB:structOnObject')

% Now perform conversion
if isobject(obj)
    if ~is_old_style_class(obj)
        names = fieldnamesIndep(obj);
        if isempty(obj)
            % Empty object, so build empty structure with correect size
            args = [names';repmat({cell(size(obj))},1,numel(names))];
            s = struct(args{:});
        else
            % Get full structure
            s = arrayfun(@(x)(structIndep_single(x,names)),obj);
        end
    else
        s = structArr(obj);
    end
elseif isstruct(obj)
    s = obj;
else
    error('HERBERT:structArrIndep:invalid_argument',...
        'Input argument is not an object or a structure. It has class %s', class(obj))
end

%----------------------------------------------------------------------------
function s = structIndep_single(obj,names)
% Convert a scalar object without having to get the names each time
args = [names';repmat({[]},1,numel(names))];
% Create empty structure with independent fields
s = struct(args{:});
% Get all properties, public, hidden, and private using Matlab intrinsic struct
% This is necessary as independent fields may be hidden or private, and so not
% accessible via the usual get methods for properties. It can be expensive,
% however, as dependent properties that are expensive to compute will be unused
stot = struct(obj);
% Pick out named properties
for i = 1:numel(names)
    s.(names{i}) = stot.(names{i});
end
