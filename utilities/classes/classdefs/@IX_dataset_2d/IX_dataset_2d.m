function w = IX_dataset_2d(varargin)
% Create IX_dataset_2d object
%
%   >> w = IX_dataset_2d (x,y)
%   >> w = IX_dataset_2d (x,y,signal)
%   >> w = IX_dataset_2d (x,y,signal,error)
%   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
%   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis,x_distribution,y_distribution)
%   >> w = IX_dataset_2d (title, signal, error, s_axis, x, x_axis, x_distribution, y, y_axis, y_distribution)
%
%  Creates an IX_dataset_2d object with the following elements:
%
% 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (vector)
% 	error				        		Standard error (vector)
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x					double      	Values of bin boundaries (if histogram data)
% 						                Values of data point positions (if point data)
% 	x_axis				IX_axis			x-axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
%
%   y                   double          -|
%   y_axis              IX_axis          |- same as above but for y-axis
%   y_distribution      logical         -|

% Default class
% (should make this call checkfields, but is so simple...)
if nargin==0
    w.title={};
    w.signal=[];
    w.error=[];
    w.s_axis=IX_axis;
    w.x=[];
    w.x_axis=IX_axis;
    w.x_distribution=false;
    w.y=[];
    w.y_axis=IX_axis;
    w.y_distribution=false;
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_2d'); return, else error(mess); end
    return
end

% Various input options
if nargin==1 && isa(varargin{1},'IX_dataset_2d')  % if already IX_dataset_2d object, return
    w=varargin{1};

elseif nargin==1 && isstruct(varargin{1})   % structure input
    [ok,mess,w]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_2d'); return, else error(mess); end

elseif nargin>=2 && nargin<=4
    w.title={};
    w.signal=[];
    w.error=[];
    w.s_axis=IX_axis;
    w.x=varargin{1};
    w.x_axis=IX_axis;
    w.x_distribution=false;
    w.y=varargin{2};
    w.y_axis=IX_axis;
    w.y_distribution=false;
    if nargin>=3, w.signal=varargin{3}; else w.signal=zeros(numel(w.x),numel(w.y)); end
    if nargin>=4, w.error=varargin{4}; else w.error=zeros(size(w.signal)); end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_2d'); return, else error(mess); end
    
elseif nargin==8 || (nargin==10 && isnumeric(varargin{1}))
    w.title=varargin{5};
    w.signal=varargin{3};
    w.error=varargin{4};
    w.s_axis=varargin{8};
    w.x=varargin{1};
    w.x_axis=varargin{6};
    if nargin==10
        w.x_distribution=varargin{9};
    else
        w.x_distribution=false;
    end
    w.y=varargin{2};
    w.y_axis=varargin{7};
    if nargin==10
        w.y_distribution=varargin{10};
    else
        w.y_distribution=false;
    end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_2d'); return, else error(mess); end

elseif nargin==10
    w.title=varargin{1};
    w.signal=varargin{2};
    w.error=varargin{3};
    w.s_axis=varargin{4};
    w.x=varargin{5};
    w.x_axis=varargin{6};
    w.x_distribution=varargin{7};   
    w.y=varargin{8};
    w.y_axis=varargin{9};
    w.y_distribution=varargin{10};
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_2d'); return, else error(mess); end
    
else
    error('Check number and type of arguments')
end
