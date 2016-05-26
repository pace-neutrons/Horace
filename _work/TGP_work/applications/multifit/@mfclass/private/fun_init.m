function obj = fun_init (ndatatot, islocal_fore, islocal_back)
% Initialise function properties for the current number of datasets
%
% Initialise foreground and background:
%   >> obj = fun_init (ndatatot)
%   >> obj = fun_init (ndatatot, islocal_fore, islocal_back)
%
% Input:
% ------
%   ndatatot        Number of data sets
%
%   islocal_fore    True if local foreground, false if global
%                   If not present or empty, set default:
%                       foreground_is_local_ == false
%
%   islocal_back    True if local background, false if global
%                   If not present or empty, set default:
%                       background_is_local_ == true
%
% Output:
% -------
%   obj             Functions structure: fields are 
%                       foreground_is_local_, fun_, pin_, np_,
%                       background_is_local_, bfun_, bpin_, nbp_


if nargin==1 || isempty(islocal_fore)
    islocal_fore = false;
end

if nargin==1 || isempty(islocal_back)
    islocal_back = true;
end

obj.foreground_is_local_ = islocal_fore;
[obj.fun_, obj.pin_, obj.np_] = init (ndatatot, islocal_fore);

obj.background_is_local_ = islocal_back;
[obj.bfun_, obj.bpin_, obj.nbp_] = init (ndatatot, islocal_back);


%------------------------------------------------------------------------------
function [fun_, pin_, np_] = init (ndatatot, islocal)

% Determine how many functions must be given
if islocal
    nfun=ndatatot;
else
    if ndatatot==0
        nfun = 0;
    else
        nfun = 1;
    end
end
% Insert elements into arrays
fun_ = cell(1,nfun);
pin_ = cell(1,nfun);
np_  = zeros(1,nfun);
