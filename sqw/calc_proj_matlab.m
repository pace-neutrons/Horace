function [u] = calc_proj_matlab (c, q)
%-----------------------------------------------------------------------
%      MATLAB-file to convert Q from spectrometer coordinates
%      to components along momentum projection axes
% 
%      Syntax:
%      >> u = calc_proj_matlab (c, q)
% 
%      c(3,3)          Matrix to convert components from
%                         spectrometer frame to projection axes
%      q(4,npix)       Coordinates of momentum  & energy transfer 
%                     in spectrometer frame
% 
%      u(4,npix)       Coordinates along projection axes
% 
%-----------------------------------------------------------------------
% Calculate projections
npix=size(q,2);
u=zeros(4,npix);

for i=1:npix,
          u(1,i)=c(1,1)*q(1,i)+c(1,2)*q(2,i)+c(1,3)*q(3,i);
          u(2,i)=c(2,1)*q(1,i)+c(2,2)*q(2,i)+c(2,3)*q(3,i);
          u(3,i)=c(3,1)*q(1,i)+c(3,2)*q(2,i)+c(3,3)*q(3,i);
          u(4,i)=q(4,i);
end
