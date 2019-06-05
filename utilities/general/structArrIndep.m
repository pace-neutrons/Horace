function s = structArrIndep(obj)
% Return the independent properties of an object array as a structure array
%
%   >> s = structArrIndep(obj)
%
% Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
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
% See also structIndep, structPublic, structArrPublic


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
            args = [names';repmat(cell(size(obj)),1,numel(names))];
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
    error('Invalid input argument type. Input must be an object or a structure')
end

%----------------------------------------------------------------------------
function s = structIndep_single(obj,names)
% Convert a scalar object without having to get the names each time
args = [names';repmat({[]},1,numel(names))];
s = struct(args{:});
stot = struct(obj);     % all properties, public, hidden, and private
% Pick out named properties
for i = 1:numel(names)
    s.(names{i}) = stot.(names{i});
end
