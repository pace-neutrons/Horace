function dout=mult_eps(din,pwr)
% Multiply dataset by a power of energy transfer
% Assumes that the energy axis is always the last axis in the dataset.
% Is called using the dnd_user_func routine. 
%
% syntax:
%   >> dout= user_func(din, @mult_eps, pwr)
%
% Input:
% ------
%   din     input dataset
%   pwr     power of energy transfer
%
% Output:
% -------
%   dout    output data structure containing dout.s, dout.e, dout.title
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% trick to avoid divide by zero warning
warning_status = warning('query');
warning off

% Check and extract input paramaters
if nargin==1,
    dout.s=din.s;
    dout.e=din.e;
    dout.title=din.title;
    return
elseif ~isnumeric(pwr) | length(pwr)>1
    error('ERROR: must give power of energy transfer');
end

% obtain the energy axis
np= find(din.pax==4);
en=eval(['din.p',num2str(np),';']);

% Apply the Bose correction
naxis=length(din.pax);
for i=1:length(en)-1
    hw= (en(i)+en(i+1))/2;
    scale=hw^pwr;
    if naxis==1,    % 1D dataset
        dout.s(i,1)= din.s(i)*scale;
        dout.e(i,1)= abs(din.e(i)*scale);
    elseif naxis==2    % 2D dataset
        dout.s(:,i)= din.s(:,i)*scale;
        dout.e(:,i)= abs(din.e(:,i)*scale);
    elseif naxis==3    % 3D dataset
        dout.s(:,:,i)= din.s(:,:,i)*scale;
        dout.e(:,:,i)= abs(din.e(:,:,i)*scale);
    else    % 4D dataset
        dout.s(:,:,:,i)= din.s(:,:,:,i)*scale;
        dout.e(:,:,:,i)= abs(din.e(:,:,:,i)*scale);
    end
end
dout.title= [din.title, ' * (hw^', num2str(pwr), ')'];

% return to original warning status
warning(warning_status);