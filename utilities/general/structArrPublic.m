function s = structArrPublic(obj)
% Return the public properties of an object array as a structure array
%
%   >> s = structArrPublic(obj)
%
% Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
% intrinsic function struct.
%
% Has the same behaviour as the Matlab instrinsic struct in that:
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
%
% However, differs in the behaviour if an object array:
% - If the object is non-empty array, returns a structure array of the same
%   size. This is different to the instrinsic Matlab, which returns a scalar
%   structure from the first element in the array of objects
%
%
% See also structPublic, structIndep, structArrIndep


if isobject(obj)
    if ~is_old_style_class(obj)
        names = fieldnames(obj);
        if isempty(obj)
            % Empty object, so build empty structure with correect size
            args = [names';repmat(cell(size(obj)),1,numel(names))];
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
    error('Invalid input argument type. Input must be an object or a structure')
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
