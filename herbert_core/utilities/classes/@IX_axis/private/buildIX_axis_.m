function  axis = buildIX_axis_(axis,varargin)
% Build IX axis object and set up its internal fields
%

narg=nargin-1;


% Various input options
if narg==1 && isa(varargin{1},'IX_axis')  % if already IX_axis object, return
    axis=varargin{1};
    return
end

if narg==1 && isstruct(varargin{1})   % structure input
    axis = axis.init_from_structure(varargin{1});
elseif narg<=4 && isstruct(varargin{end})    % final argument is structure
    nch=narg-1;
    if nch>=1, axis.caption=varargin{1}; end
    if nch>=2, axis.units=varargin{2};  end
    if nch>=3, axis.code=varargin{3};  end
    axis.ticks=varargin{end};
    
elseif narg<=4 && isnumeric(varargin{end})   % final argument is numeric array
    nch=narg-1;
    if nch>=1, axis.caption=varargin{1};  end
    if nch>=2, axis.units=varargin{2};   end
    if nch>=3, axis.code=varargin{3};   end
    if ~isempty(varargin{end})
        tc = struct('positions',[],'labels',{{}});
        tc.positions = varargin{end}(:);
        tc.labels = repmat(' ',numel(tc.positions),1);
        axis.ticks = tc;
    end
    
elseif narg>1 && narg<=5 && isnumeric(varargin{end-1}) % penultimate argument is numeric array
    nch=narg-2;
    if nch>=1, axis.caption=varargin{1}; end
    if nch>=2, axis.units=varargin{2}; end
    if nch>=3, axis.code=varargin{3};  end
    tc = struct('positions',[],'labels',{{}});
    tc.positions = varargin{end-1};
    tc.labels    = varargin{end};
    axis.ticks = tc;
    if ~isempty(varargin{end-1}), axis.ticks_.positions =varargin{end-1}; end
    if ~isempty(varargin{end}), axis.ticks_.labels=varargin{end}; end
elseif narg<=3
    nch=narg;
    if nch>=1, axis.caption=varargin{1};end
    if nch>=2, axis.units=varargin{2};  end
    if nch>=3, axis.code=varargin{3}; end    
else
    error('IX_axis:invalid_argument',...
        'wrong number and type of input arguments')
end


