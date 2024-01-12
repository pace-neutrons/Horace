function [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals)
% Append a set of values to a buffer array, doubling its number of elements
% if there is not enough space left in the buffer in anticipation of further
% accumulation.
%
% Use this rather than the Matlab intrinsic cat function to reduce the amount of
% memory reallocation should there a large number of accumulations.
%
% To create a buffer:
%   >> [buffer, nel] = accumulate_array_to_buffer (buffer_size)
%
%       Creates an array size buffer_size filled with NaNs and sets nel=0)
%
% Append to an existing array:
%   >> [buffer, nel] = accumulate_array_to_buffer (buffer, nel, appendvals)
%
% Note: you can use an pre-existing array as a buffer, although for clarity in
% code it may be worth creating a buffer and appending to it as two separate
% steps.
%
%
% Input:
% ------
% *** Creation of a buffer:
%   buffer_size Size of matlab array to be created e.g.
%
% *** Appending to existing array:
%   buffer      Current buffer array
%   nel         The number of elements currently filled. If [], then the 
%               function assumes that the buffer is completely full
%   appendvals  Array of values to eppend to the buffer
%
%
%
% Output:
% -------
%   buffer      Creation: Newly created buffer, filled with NaN
%               Appending: Updated buffer array.
%               - If the buffer has sufficient space to hold the additional 
%                 values in val, then only those elements are updated in-place
%               - If the buffer has insufficient space, then memory is
%                 allocated to hold twice the number of elements required to
%                 hold the input buffer and the additional values. The excess
%                 elements are set to NaN.
%               
%               Shape of the buffer array:
%               - If the buffer on input was large enough to accommodate vals,
%                 then the size and shape of the buffer are unchanged.
%               - If the buffer size was increased, then it is returned as a
%                 column vector, unless on input it was unambiguously a row
%                 vector. Note in the case of empty or scalar buffer:
%                   input buffer size: [0,0]   output size: [nel,1]
%                   input buffer size: [1,0]   output size: [1,nel] (as empty row)
%                   input buffer size: [0,1]   output size: [nel,1]
%                   input buffer size: [1,1]   output size: [nel,1]
%                        (as a scalar is ambiguous: it is both a row and a column)
%
%   nel         Creation: Number of filled elements is zero, i.e. nel = 0
%               Appending: The updated total number of values

% Catch case of creating a buffer
if nargin==1
    buffer = NaN(buffer);
    nel = 0;
    return
end

% Accumulate to buffer
nel_add = numel(vals);
nel_max = numel(buffer);
if isempty(nel)
    nel = nel_max;
elseif nel > nel_max
    error('HERBERT:accumulate_array_to_buffer:invalid_argument',...
        'Declared number of filled elements in buffer exceeds size')
end
nel_out = nel + nel_add;     % number of elements in accumulated output
if nel_max < nel_out
    % Need to increase buffer size
    % Double the length beyond what is needed to hold output to give space for
    % future accumulation in the buffer
    make_buffer_row = isvector(buffer) && ~iscolumn(buffer);
    buffer = [buffer(:); NaN(2*nel_out - nel_max, 1)];  % column vector
    if make_buffer_row
        buffer = buffer';
    end
end
buffer(nel+1:nel_out) = vals;
nel = nel_out;
