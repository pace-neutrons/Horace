function f=transmission(obj, varargin)
% Calculate transmission of double disk chopper (unit transmission at optimum)
%
%   >> f = transmission(obj)
%   >> f = transmission(obj, ei)
%
% For a disk chopper this is a trivial function, as it is unity for all
% incident energies. Compare with a Fermi chopper, where this is not the case.
%
% Input:
% -------
%   obj     IX_doubledisk_chopper object (scalar)
%
%   ei      Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   f       Relative transmission (in fact unity for all energies)


if ~isscalar(obj)
    error('IX_doubledisk_chopper:transmission:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

if nargin==1
    f = 1;
elseif nargin==2
    f = ones(size(varargin{1}));
else
    error('IX_doubledisk_chopper:transmission:invalid_argument',...
        'Check number of input arguments')
end

end
