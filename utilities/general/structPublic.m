function s = structPublic(obj)
% Return the public properties of an object as a structure
%
%   >> s = structPublic(obj)
%
% Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
%
% Has the same behaviour as struct in that
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
% - If the object is non-empty array, returns a scalar structure corresponding
%   to the the first element in the array of objects
%
%
% See also structIndep, structArrPublic, structArrIndep


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
    error('Invalid input argument type. Input must be an object or a structure')
end
