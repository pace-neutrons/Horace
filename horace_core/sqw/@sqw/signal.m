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



if nargin~=2
    error('HORACE:sqw:invalid_argument', ...
        'this function requests two input arguments')
elseif isempty(name)||~ischar(name)||size(name,1)~=1
    error('HORACE:sqw:invalid_argument', ...
        'Second argument of this function should be char string selected from input list. Its type is %s',...
        class(name));
end

% Get new signal array
[svals,spix,svar,sdevsqr]=coordinates_calc_(w,name);

wout=w;
wout.data.s=svals;
wout.data.e=svar;
wout.pix = PixelData([wout.pix.data(1:7,:);spix';sdevsqr']);
