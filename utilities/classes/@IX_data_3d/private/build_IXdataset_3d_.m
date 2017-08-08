function obj = build_IXdataset_3d_(obj,varargin)
% construct IX_dataset_3d object
%
%   >> w = build_IXdataset_3d_(obj,other_obj)
%   >> w = build_IXdataset_3d_(obj,x,y,z)
%   >> w = build_IXdataset_3d_(obj,x,y,z,signal)
%   >> w = build_IXdataset_3d_(obj,x,y,z,signal,error)
%   >> w = build_IXdataset_3d_(obj,x,y,z,signal,error,x_distribution,y_distribution,z_distribution)
%   >> w = build_IXdataset_3d_(obj,x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
%   >> w = build_IXdataset_3d_(obj,x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
%   >> w = build_IXdataset_3d_(obj,title, signal, error, s_axis, x, x_axis, x_distribution,...
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
    obj.xyz_{1} = obj.check_xyz(varargin{1});
    obj.xyz_{2} = obj.check_xyz(varargin{2});
    obj.xyz_{3} = obj.check_xyz(varargin{3});
    obj.xyz_distribution_=true(3,1);
    if nargin>4
        obj = check_and_set_sig_err(obj,'signal',varargin{4});
    else
        obj.signal_ = zeros(numel(obj.xyz_{1}),numel(obj.xyz_{2}),numel(obj.xyz_{3}));
    end
    if nargin>5
        obj = check_and_set_sig_err(obj,'error',varargin{5});
    else
        obj.error_=zeros(size(obj.signal_));
    end
elseif nargin ==9
    obj.xyz_{1}        =  obj.check_xyz(varargin{1});
    obj.xyz_{2}        =  obj.check_xyz(varargin{2});
    obj.xyz_{2}        =  obj.check_xyz(varargin{3});
    obj = check_and_set_sig_err_(obj,'signal',varargin{4});
    obj = check_and_set_sig_err_(obj,'error',varargin{5});
    
    obj.xyz_distribution_(1)= logical(varargin{6});
    obj.xyz_distribution_(2)= logical(varargin{7});
    obj.xyz_distribution_(3)= logical(varargin{8});
elseif nargin==11 || (nargin==14 && isnumeric(varargin{1}))
    obj.xyz_{1} = obj.check_xyz(varargin{1});
    obj.xyz_{2} = obj.check_xyz(varargin{2});
    obj.xyz_{3} = obj.check_xyz(varargin{3});
    
    obj.title=varargin{6};
    obj.x_axis=varargin{7};
    obj.y_axis=varargin{8};
    obj.z_axis=varargin{9};
    obj.s_axis=varargin{10};
    
    obj = check_and_set_sig_err(obj,'signal',varargin{4});
    obj = check_and_set_sig_err(obj,'error',varargin{5});
    
    if nargin==14
        obj.xyz_distribution_ = ...
            [logical(varargin{11});logical(varargin{12});logical(varargin{13})];
    else
        obj.xyz_distribution_=true(3,1);
    end
    
elseif nargin==14
    obj.title=varargin{1};
    
    obj.xyz_{1} = obj.check_xyz(varargin{5});
    obj.xyz_{2} = obj.check_xyz(varargin{8});
    obj.xyz_{3} = obj.check_xyz(varargin{11});
    
    obj.s_axis=varargin{4};
    obj.x_axis=varargin{6};
    obj.y_axis=varargin{9};
    obj.z_axis=varargin{12};
    
    
    obj = check_and_set_sig_err(obj,'signal',varargin{2});
    obj = check_and_set_sig_err(obj,'error',varargin{3});
    obj.xyz_distribution_ = ...
        [logical(varargin{7});logical(varargin{10});logical(varargin{13})];
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


