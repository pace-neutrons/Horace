function dout=bkgd_expon(din,amp,tau,const)
% Subtract an exponential of energy transfer
% Assumes that the energy axis is always the last axis in the dataset.
% Is called using the dnd_user_func routine. 
%
% syntax:
%   >> dout= user_func(din, @kkgd_expon, amp, tau, const)
%
% Input:
% ------
%   din     input dataset
%   amp     -|
%   tau      |- subtracts (amp*exp(-hw/tau) + const)
%   const   -|
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
end

% obtain the energy axis
np= find(din.pax==4);
en=eval(['din.p',num2str(np),';']);

% Apply the Bose correction
naxis=length(din.pax);
for i=1:length(en)-1
    hw= (en(i)+en(i+1))/2;
    bkgd = amp*exp(-hw/tau) + const;
    if naxis==1,    % 1D dataset
        dout.s(i,1)= din.s(i)-bkgd*din.n(i);
        dout.e(i,1)= din.e(i);
    elseif naxis==2    % 2D dataset
        dout.s(:,i)= din.s(:,i)-bkgd*din.n(:,i);
        dout.e(:,i)= din.e(:,i);
    elseif naxis==3    % 3D dataset
        dout.s(:,:,i)= din.s(:,:,i)-bkgd*din.n(:,:,i);
        dout.e(:,:,i)= din.e(:,:,i);
    else    % 4D dataset
        dout.s(:,:,:,i)= din.s(:,:,:,i)-bkgd*din.n(:,:,:,i);
        dout.e(:,:,:,i)= din.e(:,:,:,i);
    end
end

% return to original warning status
warning(warning_status);