function  save_xye(obj,varargin)
% Save 1D,2D,.. sqw or dnd object to ascii file.
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
% You can always substitute a different value e.g. -10^30 or 0 by
% assigning a value to the optional parameter null_value.
%
% Note that if w is an array of objects, then "file" must be a cell array
% of filenames.
%
%
% The data is saved in the format:
% 1D dataset:
%       x(1)    y(1)    e(1)
%       x(2)    y(2)    e(2)
%        :       :       :
%       x(n)    y(n)    e(n)
%
%
% 2D dataset:
%       x1(1)   x2(1)    y(1,1)    e(1,1)
%       x1(2)   x2(1)    y(2,1)    e(2,1)
%        :       :          :        :
%       x1(n1)  x2(1)    y(n1,1)   e(n1,1)
%       x1(1)   x2(2)    y(1,2)    e(1,2)
%       x1(2)   x2(2)    y(2,2)    e(2,2)
%        :       :          :        :
%       x1(n1)  x2(2)    y(n1,2)   e(n1,2)
%       x1(1)   x2(3)    y(1,3)    e(1,3)
%        :       :          :        :
%       x1(n1)  x2(n2)   y(n1,n2)  e(n1,n2)
%
%
% 3D dataset:
%       x1(1)   x2(1)    x3(1)      y(1,1)    e(1,1)
%       x1(2)   x2(1)    x3(1)      y(2,1)    e(2,1)
%        :       :          :          :        :
%       x1(n1)  x2(1)    x3(1)      y(n1,1)   e(n1,1)
%       x1(1)   x2(2)    x3(1)      y(1,2)    e(1,2)
%       x1(2)   x2(2)    x3(1)      y(2,2)    e(2,2)
%        :       :          :          :        :

% T.G.Perring  25/6/09

% Modified RAE 29/11/10 to work with arrays of sqw objects

save_xye_(obj,varargin{:});
end
