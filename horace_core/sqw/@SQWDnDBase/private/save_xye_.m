function save_xye_(obj,varargin)
% Save 1D,2D,.. sqw object to ascii file.
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

% Check input
% -----------
%TODO: when data_sqw_dnd inherits DnDBase format, remove this and
% the row:
% function save_xye_internal(obj,varargin)
% and move the code to DnDBase/private. Ticket #730
if isprop(obj,'data')
    save_xye_internal(obj.data,varargin{:});
else
    save_xye_internal(obj,varargin{:});
end

function save_xye_internal(obj,varargin)
file_given=false;
nargs=length(varargin);
null_value = NaN;
if nargs==1 && isnumeric(varargin{1})
    null_value=varargin{1};
elseif nargs==1 && (ischar(varargin{1}) || iscell(varargin{1}))
    file_given=true;
    file=varargin{1};
elseif nargs==2 && isnumeric(varargin{1}) && (ischar(varargin{2}) || iscell(varargin{2}))
    null_value=varargin{1};
    file_given=true;
    file=varargin{2};
elseif nargs~=0
    error('HORACE:save_xye:invalid_argument', ...
        'Wrong number of input parameters')
end


if file_given && numel(obj)>1
    if ~iscell(file) || numel(file)~=numel(obj)
        error('HORACE:save_xye:invalid_argument', ...
            'If an array of objects is to be saved then you must specify the filenames with a cell array of the same size');
    end
elseif file_given && numel(obj)==1
    if iscell(file) && numel(file)~=1
        error('HORACE:save_xye:invalid_argument', ...
            'Only a single object to be saved, but a cell array of filenames has been specified. Choose one filename');
    elseif iscell(file)
        file=char(file);%convert to a character array
    end
end


% Get file name - prompting if necessary
file_internal=cell(1,numel(obj));
if ~file_given
    for i=1:numel(obj)
        file_internal{i} = putfile('*.txt');
        if (isempty(file_internal{i}))
            error('HORACE:save_xye:invalid_argument', ...
                'No file to save name is provied')
        end
    end
elseif numel(obj)==1
    file_internal = {file};
else
    file_internal = file;
end

fmt_token='%-20g';
for i=1:numel(obj)
    % Get x-y-e data
    [x,y,e]=get_xye(obj(i),null_value);

    %define format
    col_format = arrayfun(@(x)(fmt_token),1:size(x,2)+2,'UniformOutput',false);
    fmt = strjoin(col_format,' ');
    fmt = [' ',fmt,'\n'];

    % write data to file
    fid = fopen (file_internal{i}, 'wt');
    if (fid < 0)
        error ('HORACE:save_xye:runtime_error', ...
            'ERROR: cannot open file: %s', file_internal{i})
    end

    fprintf (fid, fmt, [x, y, e]');

    fclose(fid);
end


%==============================================

function [x,y,e]=get_xye(w,null_value)
% Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
%
%   >> [x,y,e]=get_xye(w, null_value)
%
% Input:
% ------
%   w           Result of a cut or slice (1D, 2D,...)
%   null_value  Numeric value to substitute for the intensity in bins
%           with no data.
%           Default: NaN
%           The error bar will always be set to zero.
%
% Output:
% -------
%   x       m x n array of the x coordinates of the bin centres
%           m = number of points in the cut, n=dimensionality
%           The order of the points is usual Fortran order
%           (1,1,1), (2,1,1), ... (n1,1,1),(1,2,1),(2,2,1),...
%
%   y       m x 1 array of intensities
%
%   e       m x 1 array of error bars
%

x=w.p;
y=w.s;
e=sqrt(w.e);
empty=~logical(w.npix);

for i=1:numel(x)
    x{i}=0.5*(x{i}(2:end)+x{i}(1:end-1));
end

if numel(x)==1
    x=[x{1}];   % make a vector
else
    xx=cell(size(x));
    [xx{:}]=ndgrid(x{:});   % make grid that covers all bins
    for i=1:numel(xx)
        xx{i}=xx{i}(:);     % make each coordinate a column array
    end
    x=[xx{:}];   % concatenate arrays
end
y(empty)=null_value;
e(empty)=0;
if size(x,2) ~= w.n_dims
    x=x';
end
y=y(:);     % make column array
e=e(:);
