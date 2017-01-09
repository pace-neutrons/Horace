function f=transmission(disk,varargin)
% Calculate transmission of chopper (unit transmission at optimum)
%
%   >> f=transmission(disk)
%   >> f=transmission(disk,ei)
%
% For a disk chopper this is a trivial function, as it is unity for all
% incident energies. Compare with Fermi chopper, where this is not the case.
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, use the ei value in the chopper object
%
% Output:
% -------
%   f       Relative transmission (in fact unit transmission in all cases)

if ~isscalar(disk), error('Function only takes a scalar object'), end

if nargin==1
    f=1;
elseif nargin==2
    f=ones(size(varargin{1}));
else
    error('Check number of input arguments')
end
