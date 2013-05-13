function m=cell2mat_obj(c)
%CELL2MAT_OBJECT Convert the contents of a cell array of objects into a single matrix.
%
% Core bit of code taken from the end of matlab intrinsic CELL2MAT. For some reason,
% this code throws an error if the routine is provided with a cell array of objects.
% This routine performs the conversion for cell arrays of objects

if nargin==0, error('No input argument provided - one and only one cell array is required'), end
if ~iscell(c), error('Input argument is not a cell array'), end
if isempty(c), m=[]; return, end     % Return on empty input
if ~isobject(c{1}); error('Input is not cell array of objects'), end

% Check all cells are objects of the same class - this may be time consuming
classtype=class(c{1});
for i=1:numel(c)
    if ~isa(c{i},classtype)
        error('Not all elements of the cell array hace the same class')
    end
end

% Combine into an array of the class type
% -------------------------------------------------------------------------------------------------
% The following code is a copy of that part of cell2mat that performs the conversion
% Copyright 1984-2006 The MathWorks, Inc.

csize = size(c);
% Treat 3+ dimension arrays

% Construct the matrix by concatenating each dimension of the cell array into
%   a temporary cell array, CT
% The exterior loop iterates one time less than the number of dimensions,
%   and the final dimension (dimension 1) concatenation occurs after the loops

% Loop through the cell array dimensions in reverse order to perform the
%   sequential concatenations
for cdim=(length(csize)-1):-1:1
    % Pre-calculated outside the next loop for efficiency
    ct = cell([csize(1:cdim) 1]);
    cts = size(ct);
    ctsl = length(cts);
    mref = {};

    % Concatenate the dimension, (CDIM+1), at each element in the temporary cell
    %   array, CT
    for mind=1:prod(cts)
        [mref{1:ctsl}] = ind2sub(cts,mind);
        % Treat a size [N 1] array as size [N], since this is how the indices
        %   are found to calculate CT
        if ctsl==2 && cts(2)==1
            mref = {mref{1}};
        end
        % Perform the concatenation along the (CDIM+1) dimension
        ct{mref{:}} = cat(cdim+1,c{mref{:},:});
    end
    % Replace M with the new temporarily concatenated cell array, CT
    c = ct;
end

% Finally, concatenate the final rows of cells into a matrix
m = cat(1,c{:});
