function s = structArrPublic(obj)
% Return the public properties of an object array as a structure array
%
%   >> s = structArrPublic(obj)
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
% See also structArr, structArrIndep, struct, structPublic, structIndep


if isobject(obj)
    if ~is_old_style_class(obj)
        names = fieldnames(obj);
        if isempty(obj)
            % Empty object, so build empty structure with correect size
            args = [names';repmat({cell(size(obj))},1,numel(names))];
            s = struct(args{:});
        else
            % Get full structure
            s = arrayfun(@(x)(structPublic_single(x,names)),obj);
        end
    else
        s = structArr(obj);
    end
elseif isstruct(obj)
    s = obj;
else
    error('HERBERT:structArrPublic:invalid_argument',...
        'Input argument is not an object or a structure. It has class %s', class(obj))
end

%----------------------------------------------------------------------------
function s = structPublic_single(obj,names)
% Convert a scalar object without having to get the names each time
args = [names';repmat({[]},1,numel(names))];
s = struct(args{:});
% Pick out named properties
for i = 1:numel(names)
    s.(names{i}) = obj.(names{i});
end
