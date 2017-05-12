function proj =proj_constructor_(proj,varargin)
% non-default constructor for aProjection class
%
%
if nargin == 1
    return
elseif nargin == 2
    if isstruct(varargin{1})
        str_in = varargin{1};
        proj = build_4D_proj_box_(proj,str_in.grid_size,str_in.data_range);
        proj.projaxes_ = projaxes(str_in);
    elseif isa(varargin{1},'aProjection') %copy constructor
        proj = varargin{1};
    else
        error('APROJECTION:invalid_argument',...
            'non-empty projection needs at least grid_size_in and data_range to be defined');
    end
elseif nargin>1
    proj = build_4D_proj_box_(proj,varargin{1},varargin{2});
end
if nargin>2
    proj.projaxes_ = projaxes(varargin{3:end});
end

