function dout= bose(din,temp)
% Bose function. Multiply X''(Q,w) by this function to get S(Q,w)
% Is called using the dnd_user_func routine. It assumes that the energy 
% axis is always the last axis in the dataset.
%
% syntax:
%   >> wout= user_func(win, @bose, temperature(K))
%
% Input:
% ------
%   din     input dataset that needs to be Bose corrected
%   t       temperature (K)
%
% Output:
% -------
%   dout    output data structure containing dout.s, dout.e, dout.title
%
%   dout.s= din.s*1/(1-exp(-hw/KbT))

% Original author: J. van Duijn
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
elseif ~isnumeric(temp) | length(temp)>1
    error('ERROR: temperature needs to be given for the Bose correction to work');
end

% obtain the energy axis
np= find(din.pax==4);
en=eval(['din.p',num2str(np),';']);

% Apply the Bose correction
naxis=length(din.pax);
for i=1:length(en)-1
    hw= (en(i)+en(i+1))/2;
    Bose= 1/(1-exp(-hw*11.604/temp));
    if naxis==1,    % 1D dataset
        dout.s(i,1)= din.s(i)*Bose;
    elseif naxis==2    % 2D dataset
        dout.s(:,i)= din.s(:,i)*Bose;
    elseif naxis==3    % 3D dataset
        dout.s(:,:,i)= din.s(:,:,i)*Bose;
    else    % 4D dataset
        dout.s(:,:,:,i)= din.s(:,:,:,i)*Bose;
    end
end
dout.title= [din.title, ' Bose function(T= ', num2str(temp), ')'];
dout.e= zeros(size(din.e));

% return to original warning status
warning(warning_status);