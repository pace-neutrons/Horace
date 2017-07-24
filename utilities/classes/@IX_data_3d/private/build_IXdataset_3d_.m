function obj = build_IXdataset_3d_(obj,varargin)
% construct IX_dataset_3d object
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


% Various input options
if nargin==2 && isa(varargin{1},'IX_dataset_3d')  % if already IX_dataset_3d object, return
    obj=varargin{1};
    return
end
if  isstruct(varargin{1})   % structure input
    obj = obj.init_from_structure(in);
elseif nargin>=4 && nargin<=6
    obj.x_ = obj.check_xyz(varargin{1});
    obj.y_ = obj.check_xyz(varargin{2});
    obj.z_ = obj.check_xyz(varargin{3});
    obj.x_distribution_=true;
    obj.y_distribution_=true;
    obj.z_distribution_=true;
    if nargin>4
        obj = check_and_set_sig_err(obj,'signal',varargin{4});
    else
        obj.signal_ = zeros(numel(obj.x_),numel(obj.y_),numel(obj.z_));
    end
    if nargin>5
        obj = check_and_set_sig_err(obj,'error',varargin{5});
    else
        obj.error_=zeros(size(obj.signal_));
    end
    
elseif nargin==11 || (nargin==14 && isnumeric(varargin{1}))
    obj.x_ = obj.check_xyz(varargin{1});
    obj.y_ = obj.check_xyz(varargin{2});
    obj.z_ = obj.check_xyz(varargin{3});
    
    obj.title=varargin{6};
    obj.x_axis=varargin{7};
    obj.y_axis=varargin{8};
    obj.z_axis=varargin{9};
    obj.s_axis=varargin{10};
    
    obj = check_and_set_sig_err(obj,'signal',varargin{4});
    obj = check_and_set_sig_err(obj,'error',varargin{5});
    
    if nargin==14
        obj.x_distribution=varargin{11};
        obj.y_distribution=varargin{12};
        obj.z_distribution=varargin{13};
    else
        obj.x_distribution_=true;
        obj.y_distribution_=true;
        obj.z_distribution_=true;
    end
    
elseif nargin==14
    obj.title=varargin{1};
    
    obj.x_ = obj.check_xyz(varargin{5});
    obj.y_ = obj.check_xyz(varargin{8});
    obj.z_ = obj.check_xyz(varargin{11});
    
    obj.s_axis=varargin{4};
    obj.x_axis=varargin{6};
    obj.y_axis=varargin{9};
    obj.z_axis=varargin{12};
    
    
    obj = check_and_set_sig_err(obj,'signal',varargin{2});
    obj = check_and_set_sig_err(obj,'error',varargin{3});
    obj.x_distribution=varargin{7};
    obj.y_distribution=varargin{10};
    obj.z_distribution=varargin{13};
else
    error('IX_data_3d:invalid_argument',...
        'Check number and type of arguments')
end

[ok,mess]=check_joint_fields_(obj);
if ok
    obj.valid_  = true;
else
    error('IX_dataset_3d:invalid_argument',mess);
end


