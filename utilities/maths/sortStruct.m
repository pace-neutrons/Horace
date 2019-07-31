function [sortedStruct, index] = sortStruct(aStruct, varargin)
% Sort a (one-dimensional) struct array
%
%   >> [sortedStruct index] = sortStruct(aStruct)
%   >> [sortedStruct index] = sortStruct(aStruct, fieldNamesCell)
%   >> [sortedStruct index] = sortStruct(..., directions)
%
% The function returns a nested sort of a (one-dimensional) struct array
% (aStruct), and can also return an index vector. The fields by which to sort are
% specified in a cell array of strings fieldNamesCell. Fields must be single numbers or
% logicals, or chars (usually simple strings).
%
% Input
% -----
%   aStruct     One-dimensional struct array (row or column)
%               The fields must be character arrays, or numeric or logical arrays
%
%   fieldNams   [Optional] name of one or more fields by which to sort the
%               structure. Single character string, or cell array of charaxter
%               strings. The structure is sorted according to the first field
%               name, then, for equal values for that field, by the second field
%               name etc.
%               Default: all fields as returned by the matlab intrinsic function
%               fieldnames
%
%   directions  [Optional] Specify whether the struct array should be sorted
%               in ascending or descending order for the fields.
%               Default: the struct array will be sorted in ascending order
%               for each field.
%
%               If supplied, directions must be:
%               - a single  1 to sort in ascending order for all fields, or
%               - a single -1 to sort in descending order for all fields, or
%               - a vector of 1's and -1's, the same length as fieldNams,
%                 where the struct array will be sorted in the order specified
%                 by directions(ii) for fieldNams(ii).
%
% Output:
% -------
%  sortedStruct Sorted structure with same shape as input struct array
%   index       Index array such that: sortedStruct = aStrcut(index)
%
%
% Toby Perring 08 Feb 2019:
% Merging and small generalisation of nestedSortStruct and sortStruct
% downloaded from Matlab file exchange 07 Feb 2019 (author Jake Hughey (2010))


% Check struct
if ~isstruct(aStruct)
    error('first input supplied is not a struct.')
end

if sum(size(aStruct)>1)>1 % if more than one non-singleton dimension
    error('I don''t want to sort your multidimensional struct array.')
end

% Parse optional arguments - just check number and assign
if numel(varargin)==0
    fieldNams = fieldnames(aStruct)';
    directions = 1;
elseif numel(varargin)==1
    if ~isnumeric(varargin{1})
        fieldNams = varargin{1};
        directions = 1;
    else
        fieldNams = fieldnames(aStruct)';
        directions = varargin{1};
    end
elseif numel(varargin)==2
    fieldNams = varargin{1};
    directions = varargin{2};
else
    error('Too many input arguments')
end

% Check fieldnames
if ~iscell(fieldNams)
    [ok, mess, sortedStruct, index] = singleSortStruct(aStruct, fieldNams, directions);
else
    [ok, mess, sortedStruct, index] = nestsedSortStruct(aStruct, fieldNams, directions);
end
if ~ok, return, else, error(mess), end

% Ensure shape (row or column) matches input (as expected from Matlabb intrinsic sort)
if size(sortedStruct,1)~=size(aStruct,1)
    sortedStruct = reshape(sortedStruct,size(aStruct));
end
if size(index,1)~=size(aStruct,1)
    index = reshape(index,size(aStruct));
end

% ========================================================================
function [ok, mess, sortedStruct, index] = nestsedSortStruct(aStruct, fieldNams, directions)
% Sort a struct array according to nested sorts on the named fields

ok=false; mess=''; sortedStruct=[]; index=[];

if ~all(isfield(aStruct, fieldNams))
    for ii=find(~isfield(aStruct, fieldNams))
        fprintf('%s is not a fieldname in the struct.\n', fieldNams{ii})
    end 
    mess = 'at least one entry in fieldNams is not a fieldname in the struct.';
    return
end

% Check classes of fieldnames
for ii=1:length(fieldNams)
    fieldEntry = aStruct(1).(fieldNams{ii});
    if ~( isnumeric(fieldEntry) || islogical(fieldEntry) || ischar(fieldEntry) )
        fprintf('%s is not a valid fieldname by which to sort.\n', fieldNams{ii})
        mess = 'at least one fieldname is not a valid one by which to sort.';
        return
    end
end

% Check directions, create if necessary (1 for ascending, -1 for descending)
if ~(isnumeric(directions) && all(ismember(directions, [-1 1])))
    error('directions, if given, must be a single number or a vector with 1 (ascending) and -1 (descending).')
end

if numel(directions)==1
    directions = directions * ones(1, length(fieldNams)); % create vector from single element
elseif length(fieldNams)~=length(directions)
    ok = false;
    mess = 'fieldNamesCell and directions vector are different lengths.';
    return
end

% fieldNamesIdx is a vector of the indices of the fields by which to sort
[~, fieldNamesIdx] = ismember(fieldNams, fieldnames(aStruct));

% Convert the struct to a cell, squeeze makes sure both row and column arrays are sorted properly, transpose for sortrows
aCell = squeeze(struct2cell(aStruct))';
lognum = cellfun(@(x)(isnumeric(x)|islogical(x)),aCell(1,:));
for ii=find(lognum)
    aCell(:,ii)=unique_index(aCell(:,ii));  % substitute with index into unique ascending sorted list
end

% sortrows of aCell, using indices from fieldNamesIdx and directions
[~, index] = sortrows(aCell, fieldNamesIdx .* directions);

sortedStruct = aStruct(index); % apply the index to the struct array

ok = true;


% ========================================================================
function [ok, mess, sortedStruct, index] = singleSortStruct(aStruct, fieldName, direction)
% Sort a struct array according to the contents of one named field

ok = false; mess = ''; sortedStruct=[]; index=[];

if ~isfield(aStruct, fieldName)
    mess = 'fieldName is not a fieldname in the struct.';
    return
end
    
if ~isnumeric(direction) || numel(direction)>1 || ~ismember(direction, [-1 1])
    mess = 'direction, if given, must equal 1 for ascending order or -1 for descending order.';
    return
end

% Figure out the field's class, and find the sorted index vector
fieldEntry = aStruct(1).(fieldName);

if (isnumeric(fieldEntry) || islogical(fieldEntry))
    if numel(fieldEntry) == 1 % if the field is a single number
        [~, index] = sort([aStruct.(fieldName)]);
    else
        [~, index] = sortrows(unique_index({aStruct.(fieldName)}));
    end
elseif ischar(fieldEntry) % if the field is char
    [~, index] = sort({aStruct.(fieldName)});
else
    mess = [fieldName, ' is not an appropriate field by which to sort.'];
    return
end

% Apply the index to the struct array
if direction == 1 % ascending sort
    sortedStruct = aStruct(index);
else % descending sort
    sortedStruct = aStruct(index(end:-1:1));
end

ok = true;


% ========================================================================
function icCell = unique_index (aCell)
% Replace entries in a cell array with unique index into ascending
% unique sorted array.
nel = cellfun(@numel,aCell);
A = -Inf(numel(aCell),max(nel(:)));
for i=1:numel(nel)
    A(i,1:nel(i)) = aCell{i}(:)';
end
[~,~,ic] = unique(A,'rows');
icCell = num2cell(ic);
