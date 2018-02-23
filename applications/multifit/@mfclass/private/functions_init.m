function Sfun = functions_init (ndatatot, islocal_fore, islocal_back)
% Initialise function properties for the current number of datasets
%
%   >> obj = functions_init (ndatatot, islocal_fore, islocal_back)
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
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


Sfun.foreground_is_local_ = islocal_fore;
[Sfun.fun_, Sfun.pin_, Sfun.np_, Sfun.free_] = init (ndatatot, islocal_fore);

Sfun.background_is_local_ = islocal_back;
[Sfun.bfun_, Sfun.bpin_, Sfun.nbp_, Sfun.bfree_] = init (ndatatot, islocal_back);


%------------------------------------------------------------------------------
function [fun_, pin_, np_, free_] = init (ndatatot, islocal)

% Determine how many functions must be given
if islocal
    nfun=ndatatot;
else
    nfun = min(1,ndatatot);    % 0 or 1
end
% Insert elements into arrays
fun_ = cell(1,nfun);
pin_ = repmat(mfclass_plist(),1,nfun);
np_  = zeros(1,nfun);
free_ = repmat({true(1,0)},1,nfun);
