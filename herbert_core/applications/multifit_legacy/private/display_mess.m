function display_mess(varargin)
% Display an arbitrary list of character arrays or cellstr to the screen
%
%   >> display_mess (c1, c2, c3,...)

for iarg=1:numel(varargin)
    if iscellstr(varargin{iarg})
        for i=1:numel(varargin{iarg})
            disp(varargin{iarg}{i})
        end
    elseif ischar(varargin{iarg}) && numel(size(varargin{iarg}))==2
        for i=1:size(varargin{iarg},1)
            disp(varargin{iarg}(i,:))
        end
    else
        error('Input argument not cellstr or character array')
    end
end
