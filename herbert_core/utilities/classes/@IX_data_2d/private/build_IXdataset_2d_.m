function obj=build_IXdataset_2d_(obj,varargin)
% Construct IX_dataset_2d object
%
% Construct from primitive properties:
%   >> w = build_IXdataset_2d_(obj, x, y)
%   >> w = build_IXdataset_2d_(obj, x, y, signal)
%
%   >> w = build_IXdataset_2d_(obj, x, y, signal, error)
%   >> w = build_IXdataset_2d_(..., x_distribution, y_distribution)
%   >> w = build_IXdataset_2d_(..., title, x_axis, y_axis, s_axis)
%   >> w = build_IXdataset_2d_(..., title, x_axis, y_axis, s_axis,...
%                                               x_distribution, y_distribution)
%
%   >> w = build_IXdataset_2d_(obj, title, signal, error, s_axis, ...
%                           x, x_axis, x_distribution, y, y_axis, y_distribution)
%
% Construct from other objects
%   >> w = build_IXdataset_2d_(obj, other_obj)
%
% Creates an IX_dataset_2d object (or array of objects) with the following
% elements:
%
%   title               char/cellstr    Title of dataset for plotting purposes (character array or cellstr)
%   signal              double          Signal (2D array)
%   error                               Standard error (2D array)
%   s_axis              IX_axis         Signal axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%   x                   double          Values of bin boundaries (if histogram data)
%                                       Values of data point positions (if point data)
%   x_axis              IX_axis         x-axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%   x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
%
%   y                   double          -|
%   y_axis              IX_axis          |- same as above but for y-axis
%   y_distribution      logical         -|


obj.do_check_combo_arg_ = false;

% If already an IX_dataset_2d object or array of objects, return
if nargin==2 && isa(varargin{1},'IX_dataset_2d')
    obj=varargin{1};
    return;
end

% Create an IX_dataset_2d object or array of objects from an IX_dataset_1d
% object or array of objects.
% Contiguous IX_dataset_1d objects in the array that share the same x-axis and
% point/histogram mode will be 'stacked' to form a single IX_dataset_2d in the
% output.
if nargin == 2 && isa(varargin{1},'IX_dataset_1d')
    obj = build_from_IX_dataset_1d_(obj, varargin{:});
    for i=1:numel(obj)
        obj(i).do_check_combo_arg_ = true;
        obj(i) = check_combo_arg(obj(i));
    end

    return;
end

% Create IX_dataset_2d or array of IX_dataset_2d from a structure input
if nargin==2 && isstruct(varargin{1})
    obj = obj.loadobj(varargin{1});
    return;
end

% The various cases of constructing a single IX_dataset_1d object from
% properties with defaults for the properties not given.
if nargin>=3 && nargin<=5
    obj.xyz_{1}        = obj.check_xyz(varargin{1});
    obj.xyz_distribution_(1)= true;
    obj.xyz_{2}        =  obj.check_xyz(varargin{2});
    obj.xyz_distribution_(2)= true;

    if nargin>=4
        obj = check_and_set_sig_err_(obj,'signal',varargin{3});
    else
        obj = check_and_set_sig_err_(obj,'signal',zeros(numel(varargin{1}),numel(varargin{2})));
    end
    if nargin>=5
        obj = check_and_set_sig_err_(obj,'error',varargin{4});
    else
        obj = check_and_set_sig_err_(obj,'error',zeros(size(obj.signal_)));
    end
    
elseif nargin ==7
    obj.xyz_{1}        = obj.check_xyz(varargin{1});
    obj.xyz_{2}        =  obj.check_xyz(varargin{2});
    obj = check_and_set_sig_err_(obj,'signal',varargin{3});
    obj = check_and_set_sig_err_(obj,'error',varargin{4});

    obj.xyz_distribution_(1)= logical(varargin{5});
    obj.xyz_distribution_(2)= logical(varargin{6});

elseif nargin==9 || (nargin==11 && isnumeric(varargin{1}))
    obj.xyz_{1}        = obj.check_xyz(varargin{1});
    obj.xyz_{2}        = obj.check_xyz(varargin{2});

    obj.title=varargin{5};
    obj = check_and_set_sig_err_(obj,'signal',varargin{3});
    obj = check_and_set_sig_err_(obj,'error',varargin{4});
    obj.x_axis=varargin{6};
    obj.s_axis=varargin{8};
    if numel(varargin)>8
        obj.x_distribution=varargin{9};
        %obj.xyz_distribution_(1)=logical(varargin{9});
    else
        obj.xyz_distribution_(1)=true;
    end
    obj.y_axis=varargin{7};
    if numel(varargin)>9
        obj.y_distribution=varargin{10};
        %obj.xyz_distribution_(2) = logical(varargin{10});
    else
        obj.xyz_distribution_(2)=true;
    end

elseif nargin==11
    obj.title=varargin{1};
    obj = check_and_set_sig_err(obj,'signal',varargin{2});
    obj = check_and_set_sig_err(obj,'error',varargin{3});

    obj.s_axis=varargin{4};
    obj.xyz_{1}  = obj.check_xyz(varargin{5});
    obj.xyz_{2}  = obj.check_xyz(varargin{8});

    obj.x_axis=varargin{6};
    obj.x_distribution=varargin{7};
    obj.y_axis=varargin{9};
    obj.y_distribution=varargin{10};
    %obj.xyz_distribution_ = logical([varargin{7},varargin{10}]);
    
else
    error('IX_dataset_2d:invalid_argument',...
        'Invalid number or type of arguments')
end

obj.do_check_combo_arg_ = true;
obj = check_combo_arg (obj);
