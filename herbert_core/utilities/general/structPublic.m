function s = structPublic(obj)
% Return the public properties of a scalar object as a structure
%
%   >> s = structPublic(obj)
%
% Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
%
% Has the same behaviour as the Matlab intrinsic struct in that:
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
% - If the object is non-empty array, returns a scalar structure corresponding
%   to the the first element in the array of objects
%
%
% See also struct, structIndep, structArr, structArrPublic, structArrIndep


if isobject(obj)
    if ~is_old_style_class(obj)
        names = fieldnames(obj);
        if isempty(obj)
            % Empty object, so build empty structure with correect size
            args = [names';repmat({cell(size(obj))},1,numel(names))];
            s = struct(args{:});
        else
            % Get structure array
            args = [names';repmat({[]},1,numel(names))];
            s = struct(args{:});
            for i = 1:numel(names)
                s.(names{i}) = obj.(names{i});
            end
        end
    else
        s = struct(obj);
    end
elseif isstruct(obj)
    s = obj;
else
    error('HERBERT:structPublic:invalid_argument',...
        'Input argument is not an object or a structure. It has class %s', class(obj))
end
