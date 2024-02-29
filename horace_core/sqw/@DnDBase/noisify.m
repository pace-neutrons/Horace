function obj = noisify(obj,varargin)
 % Noisify the dnd data directly with the Herbert noisify.

 for i=1:numel(obj)
    [obj(i).s,obj(i).e]=noisify(obj(i).s,obj(i).e,varargin{:});
 end