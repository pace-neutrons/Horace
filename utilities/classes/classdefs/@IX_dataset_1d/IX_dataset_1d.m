function w = IX_dataset_1d(varargin)
% Create IX_dataset_1d object
%
%   >> w = IX_dataset_1d (x)
%   >> w = IX_dataset_1d (x,signal)
%   >> w = IX_dataset_1d (x,signal,error)
%   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
%   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
%   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
%
%  Creates an IX_dataset_1d object with the following elements:
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

% Default class
if nargin==0
    w.title={};
    w.signal=[];
    w.error=[];
    w.s_axis=IX_axis;
    w.x=[];
    w.x_axis=IX_axis;
    w.x_distribution=false;
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_1d'); return, else error(mess); end
    return
end

% Various input options
if nargin==1 && isa(varargin{1},'IX_dataset_1d')  % if already IX_dataset_1d object, return
    w=varargin{1};

elseif nargin==1 && isstruct(varargin{1})   % structure input
    [ok,mess,w]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_1d'); return, else error(mess); end

elseif nargin<=3
    w.title={};
    w.signal=[];
    w.error=[];
    w.s_axis=IX_axis;
    w.x=[];
    w.x_axis=IX_axis;
    w.x_distribution=false;
    if nargin>=1, w.x=varargin{1}; else w.x=[]; end
    if nargin>=2, w.signal=varargin{2}; else w.signal=zeros(size(w.x)); end
    if nargin>=3, w.error=varargin{3}; else w.error=zeros(size(w.signal)); end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_1d'); return, else error(mess); end
    
elseif nargin==6 || (nargin==7 && isnumeric(varargin{1}))
    w.title=varargin{4};
    w.signal=varargin{2};
    w.error=varargin{3};
    w.s_axis=varargin{6};
    w.x=varargin{1};
    w.x_axis=varargin{5};
    if nargin==7
        w.x_distribution=varargin{7};
    else
        w.x_distribution=false;
    end
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_1d'); return, else error(mess); end

elseif nargin==7
    w.title=varargin{1};
    w.signal=varargin{2};
    w.error=varargin{3};
    w.s_axis=varargin{4};
    w.x=varargin{5};
    w.x_axis=varargin{6};
    w.x_distribution=varargin{7};   
    [ok,mess,w]=checkfields(w);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, w=class(w,'IX_dataset_1d'); return, else error(mess); end
    
else
    error('Check number of arguments')
end
