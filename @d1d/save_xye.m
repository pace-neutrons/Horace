function save_xye (w,varargin)
% Saves a one dimensional dataset to ASCII file
%
% Syntax:
%   >> save_xye (w)                 %  Prompts for file to write to
%   >> save_xye (w, null_value)     %  Substitute intensity of empty cells with
%                                   % the numerical value empty (default: NaN)
%   >> save_xye (w, file)           %  Write to named file
%   >> save_xye (w, null_value, file)
%
% Unless otherwise specified, bins where there is no data are written as
% having NaN (i.e. not-a-number) for the signal and zero for the standard deviation.
% You can always substitue a different value e.g. -10^30 or 0 by 
% assigning a value to the optional parameter null_value.
% 
%
% The data is saved in the format:
%       x(1)    y(1)    e(1)
%       x(2)    y(2)    e(2)
%        :       :       :
%       x(n)    y(n)    e(n)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

% if numel(w)~=1
%     error('Can only write a single data object to file, not an array of objects')
% end

save_xye(sqw(w),varargin{:});
