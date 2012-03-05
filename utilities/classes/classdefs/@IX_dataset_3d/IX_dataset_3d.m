function w = IX_dataset_3d(varargin)
% Create IX_dataset_3d object
%
%   >> w = IX_dataset_3d (x,y,z)
%   >> w = IX_dataset_3d (x,y,z,signal)
%   >> w = IX_dataset_3d (x,y,z,signal,error)
%   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
%   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
%   >> w = IX_dataset_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
%                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
%
%  Creates an IX_dataset_3d object with the following elements:
%
% 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (3D array)
% 	error				        		Standard error (3D array)
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
%
%   z                   double          -|
%   z_axis              IX_axis          |- same as above but for z-axis
%   z_distribution      logical         -|

superiorto('IX_dataset_1d','IX_dataset_2d')

% Default class
if nargin==0
    w.title={};
    w.signal=zeros([0,0,0]);
    w.error=zeros([0,0,0]);
    w.s_axis=IX_axis;
    w.x=zeros(1,0);
    w.x_axis=IX_axis;
    w.x_distribution=false;
    w.y=zeros(1,0);
    w.y_axis=IX_axis;
    w.y_distribution=false;
    w.z=zeros(1,0);
    w.z_axis=IX_axis;
    w.z_distribution=false;
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_3d'); return, else error(mess); end
    return
end

% Various input options
if nargin==1 && isa(varargin{1},'IX_dataset_3d')  % if already IX_dataset_3d object, return
    w=varargin{1};

elseif nargin==1 && isstruct(varargin{1})   % structure input
    [ok,mess,w]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_3d'); return, else error(mess); end

elseif nargin>=3 && nargin<=5
    w.title={};
    w.signal=zeros([0,0,0]);
    w.error=zeros([0,0,0]);
    w.s_axis=IX_axis;
    w.x=varargin{1};
    w.x_axis=IX_axis;
    w.x_distribution=false;
    w.y=varargin{2};
    w.y_axis=IX_axis;
    w.y_distribution=false;
    w.z=varargin{3};
    w.z_axis=IX_axis;
    w.z_distribution=false;
    if nargin>=4, w.signal=varargin{4}; else w.signal=zeros(numel(w.x),numel(w.y),numel(w.z)); end
    if nargin>=5, w.error=varargin{5}; else w.error=zeros(size(w.signal)); end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_3d'); return, else error(mess); end
    
elseif nargin==10 || (nargin==13 && isnumeric(varargin{1}))
    w.title=varargin{6};
    w.signal=varargin{4};
    w.error=varargin{5};
    w.s_axis=varargin{10};
    w.x=varargin{1};
    w.x_axis=varargin{7};
    if nargin==13
        w.x_distribution=varargin{11};
    else
        w.x_distribution=false;
    end
    w.y=varargin{2};
    w.y_axis=varargin{8};
    if nargin==13
        w.y_distribution=varargin{12};
    else
        w.y_distribution=false;
    end
    w.z=varargin{3};
    w.z_axis=varargin{9};
    if nargin==13
        w.z_distribution=varargin{13};
    else
        w.z_distribution=false;
    end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_3d'); return, else error(mess); end

elseif nargin==13
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
    w.z=varargin{11};
    w.z_axis=varargin{12};
    w.z_distribution=varargin{13};
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_3d'); return, else error(mess); end
    
else
    error('Check number and type of arguments')
end
