function ok=is_string(varargin)
% true if variable is a character string i.e. 1xn character array (n>=0), or empty character
%
%   >> ok=is_string(var)
%
% Note: if var is empty but has size 1x0 then will return true
%       Also, if empty, will return true

if nargin == 1
    ok=ischar(varargin{1}) && (isrowvector(varargin{1}) || isempty(varargin{1}));    
elseif nargin > 1
    ok=cellfun(@(a)(ischar(a) && (isrowvector(a) || isempty(a))),varargin,...
        'UniformOutput',true);
else
    ok= false;
end
