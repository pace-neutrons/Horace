function f=transmission(self,varargin)
% Calculate transmission of double disk chopper (unit transmission at optimum)
%
%   >> f = transmission(disk)
%   >> f = transmission(disk, ei)
%
% For a disk chopper this is a trivial function, as it is unity for all
% incident energies. Compare with a Fermi chopper, where this is not the case.
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   ei      Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   f       Relative transmission (in fact unity for all energies)


if ~isscalar(self), error('Method only takes a scalar double disk chopper object'), end

if nargin==1
    f=1;
elseif nargin==2
    f=ones(size(varargin{1}));
else
    error('Check number of input arguments')
end
