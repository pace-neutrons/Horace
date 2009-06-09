function save_xye(w,varargin)
% Save 1D,2D,.. Horace cut to ascii file.
%
% Syntax:
%   >> save_xye (w)           %  Prompts for file to write to
%   >> save_xye (w, empty)    %  Substitute intensity of empty cells with
%                             % the nmerical value empty (default: NaN)
%   >> save_xye (w, file)     %  Write to named file
%   >> save_xye (w, empty, file)
%
% The data is saved in the format:
% 1D dataset:
%       x(1)    y(1)    e(1)
%       x(2)    y(2)    e(2)
%        :       :       :
%       x(n)    y(n)    e(n)
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

% Check input
% -----------
if ~(isa(w,'d1d')||isa(w,'d2d')||isa(w,'d3d')||isa(w,'d4d'))
    error ('Data must be a Horace 1D,2D,3D or 4D object')
end

empty_given=false;
file_given=false;
nargs=length(varargin);
if nargs==1 && isnumeric(varargin{1})
    empty_given=true;
    empty=varargin{1};
elseif nargs==1 && ischar(varargin{1})
    file_given=true;
    file=varargin{1};
elseif nargs==2 && isnumeric(varargin{1}) && ischar(varargin{2})
    empty_given=true;
    empty=varargin{1};
    file_given=true;
    file=varargin{2};
elseif nargs~=0
    error('Check input parameters')
end
        

% Get file name - prompting if necessary
% --------------------------------------
if ~file_given
    file_internal = genie_putfile('*.txt');
    if (isempty(file_internal))
        error ('No file given')
    end
else
    file_internal = file;
end


% Get x-y-e data
% ---------------
if empty_given
    [x,y,e]=get_xye(w,empty);
else
    [x,y,e]=get_xye(w);
end


% write data to file
% ------------------


fid = fopen (file_internal, 'wt');
if (fid < 0)
    error (['ERROR: cannot open file ' file_internal])
end

fmt_token='%-20g';
fmt=[fmt_token,' ',fmt_token,' \n'];
for i=1:size(x,2);
    fmt=[fmt_token,' ',fmt];     % make format string
end

fprintf (fid, fmt, [x, y, e]');

fclose(fid);
    