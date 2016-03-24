function obj = cut_transf_(obj,varargin)
% Internal construnctor, defining cut transformation
%
% $Revision$ ($Date$)
%
if ~(nargin==3 || nargin==5 || nargin == 1)
    error('CUT_TRANSF:invalid_argument','cut_transf construnctor accepts none, two or four argiments')
elseif nargin==3
    obj = set_range_(obj,1,varargin{1});
    obj = set_range_(obj,2,varargin{1});
    obj = set_range_(obj,3,varargin{1});
    obj = set_range_(obj,4,varargin{2});
elseif nargin==5
    obj = set_range_(obj,1,varargin{1});
    obj = set_range_(obj,2,varargin{2});
    obj = set_range_(obj,3,varargin{3});
    obj = set_range_(obj,4,varargin{4});
end

obj.transf_matrix_ = eye(3);


