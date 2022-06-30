function s = structIndep(obj)
% Return the independent properties of an object as a structure
%
%   >> s = structIndep(obj)
%
% Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
%
% Has the same behaviour as the Matlab instrinsic struct in that:
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
% - If the object is non-empty array, returns a scalar structure corresponding
%   to the the first element in the array of objects
%
%
% See also structPublic, structArrIndep, structArrPublic


% Get warning state that we must turn of if obj is a new style object array
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
            stot = struct(obj);
            % Pick out independent properties
            args = [names';repmat({[]},1,numel(names))];
            s = struct(args{:});
            for i = 1:numel(names)
                s.(names{i}) = stot.(names{i});
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
