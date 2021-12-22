function [obj,remains] = process_positional_args_(obj,varargin)
% Process positional arguments of an ortho_projection init method
% Inputs:

%   u    if present, [1x3] Vector of first axis (r.l.u.) defining projection axes
%   v    if present, [1x3] Vector of second axis (r.l.u.) defining projection axes

%   w    if present,  [1x3] Vector of third axis (r.l.u.) - only needed if the third
%               character of argument 'type' is 'p'. Will otherwise be ignored.
% Returns:

% ortho_proj object with properties set 
if numel(varargin)>0 && isnumeric(varargin{1})
    obj = check_and_set_uv_(obj,'u',varargin{1});
else
    remains= varargin;
    return;
end
if numel(varargin)>1 && isnumeric(varargin{2})
    obj = check_and_set_uv_(obj,'v',varargin{2});    
else
    remains= varargin(2:end);
    return;
end
if numel(varargin)>2 && isnumeric(varargin{3})
    obj = check_and_set_w_(obj,varargin{3});        
    remains = varargin(4:end);    
else
    remains= varargin(3:end);
end

%


