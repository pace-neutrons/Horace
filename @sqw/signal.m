function wout=signal(w,name)
% Set the signal axis (i.e. intensity) to the values for the named argument
%
%   >> wout=signal(w,param_name)    %
%
%   e.g. >> wout=signal(w,'h')  % set to component along a*
%
%   Valid parameter names are:
%               'd1','d2',...       Display axes (for as many dimensions as sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|

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
