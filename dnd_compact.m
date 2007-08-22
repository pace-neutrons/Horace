function dout = dnd_compact (din)
% Squeezes the data range in a dataset structure to eliminate empty bins
%
% Syntax:
%   >> dout = dnd_compact(din)
%
% Input:
% ------
%   din                 Dataset structure.
%                       Type >> help dnd_checkfields for a full description of the fields
% Output:
% -------
%   dout                Output dataset structure.
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% Dimension of input data structure
ndim=length(din.pax);

% Initialise output argument
dout = din;

% Get section parameters and axis arrays:
[val, n] = data_limits (din);

for i=1:ndim
    nam = ['p',num2str(i)];
    dout.(nam)=din.(nam)(n(1,i):n(2,i)+1);
end

if ndim==1
    dout.s = din.s(n(1,1):n(2,1));
    dout.e = din.e(n(1,1):n(2,1));
elseif ndim==2
    dout.s = din.s(n(1,1):n(2,1),n(1,2):n(2,2));
    dout.e = din.e(n(1,1):n(2,1),n(1,2):n(2,2));
elseif ndim==3
    dout.s = din.s(n(1,1):n(2,1),n(1,2):n(2,2),n(1,3):n(2,3));
    dout.e = din.e(n(1,1):n(2,1),n(1,2):n(2,2),n(1,3):n(2,3));
elseif ndim==4
    dout.s = din.s(n(1,1):n(2,1),n(1,2):n(2,2),n(1,3):n(2,3),n(1,4):n(2,4));
    dout.e = din.e(n(1,1):n(2,1),n(1,2):n(2,2),n(1,3):n(2,3),n(1,4):n(2,4));
else
    error('ERROR: Logic flaw in function ''compact''')
end
    
    