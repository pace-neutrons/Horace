function wout=signal(w,name)
% Set the intensity of an sqw object to the values for the named argument
%
%   >> wout=signal(w,param_name)
%
% Input:
% -----
%   w       Input sqw object
%   name    Name of the parameter to use as the intensity
%          Valid parameter names are:
%               'd1','d2',...       Display axes (for as many dimensions as
%                                  the sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|
%
% Output:
% -------
%   wout    Output sqw object with the intensities of the pixels set to the
%          value of the input parameter name
%
% EXAMPLE
%   >> wout=signal(w,'h')   % set the intensity to the component along a*


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


if ~is_sqw_type(w)
    error('Signal change only possible for full sqw objects i.e. which have individual pixel information')
end

if nargin~=2
    error('Check number of parameters')
elseif isempty(name)||~ischar(name)||size(name,1)~=1
    error('Check type of arguments')
end

% Get new signal array
[ok,mess,svals,spix,svar,sdevsqr]=coordinates_calc(w,name);
if ~ok
    error(mess)
end

wout=w;
wout.data.s=svals;
wout.data.e=svar;
wout.data.pix=[wout.data.pix(1:7,:);spix';sdevsqr'];
