function s = structArr(obj)
% Convert the object array obj into its equivalent structure.
%
%   >> s = structArr(obj)
%
% Has the same behaviour as the Matlab intrinsic struct in that:
% - Any structure array is returned unchanged
% - If an object is empty, an empty structure is returned with fieldnames
%   but the same size as the object
% - All properties of the object are returned in the structure: public,
%   hidden and private.
%
% However, differs in the behaviour if an object array:
% - If the object is non-empty array, returns a structure array of the same
%   size. This is different to the intrinsic Matlab, which returns a scalar
%   structure from the first element in the array of objects
%
%
% See also structArrPublic, structArrIndep, struct, structPublic, structIndep


% Get warning state that we must turn of if obj is a new style object array
% If not done, then the call to Matlab intrinsic struct will throw a warning
state = warning('query','MATLAB:structOnObject');
reset_warning = onCleanup(@()warning(state));
warning('off','MATLAB:structOnObject')

% Now perform conversion
if isobject(obj)
    if isempty(obj) || numel(obj)==1
        s = struct(obj);
    else
        if ~is_old_style_class(obj)
            s = arrayfun(@struct,obj);
        else
            names = fieldnames(obj);
            args = [names';repmat({[]},1,numel(names))];
            s = repmat(struct(args{:}), size(obj));
            for i=1:numel(obj)
                s(i) = struct(obj(i));
            end
        end
    end
elseif isstruct(obj)
    s = obj;
else
    error('HERBERT:structArr:invalid_argument',...
        'Input argument is not an object or a structure. It has class %s', class(obj))
end
