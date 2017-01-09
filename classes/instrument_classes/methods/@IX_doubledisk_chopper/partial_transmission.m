function f=partial_transmission(disk,varargin)
% Calculate partial transmission integrated over [-Inf,t]
%
%   >> f=partial_transmission(disk)             % full transmission (integral over -Inf to +Inf); ==1
%                                               % independent of energy (cf. Fermi chopper)
%   >> f=partial_transmission(disk,t)           % partial transmission for an array of times
%
% If t=Inf, then returns same result as: transmission(disk)
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   t       time (microseconds) (array or scalar)
%           If omitted, use t=Inf
%
% Output:
% -------
%   f       Partial transmission (unit transmission at t=Inf)

if ~isscalar(disk), error('Function only takes a scalar object'), end

if nargin==1
    f=1;
elseif nargin==2
    t=varargin{1};     % time in microseconds
    fwhh = 1e6*disk.slot_width/(4*pi*disk.radius*disk.frequency); % FWHH of triangular profile
    f=zeros(size(t));
    ok=(abs(t)<fwhh);
    f(ok)=(t(ok)+fwhh)/(2*fwhh);
else
    error('Check number of input argumnets')
end
