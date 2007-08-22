function plot_old (w)
% plot    Plots 3D dataset using sliceomatic
%
% Syntax:
%   >> plot (w)
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions - 
%      On the 'Object_Defaults' menu select 'Slice Color Texture'

% Original author: T.G.Perring
%
% $Revision: 119 $ ($Date: 2007-02-11 14:58:06 +0000 (Sun, 11 Feb 2007) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Prepare intensity array
%   - remove zeros in w.n to avoid zero divides
%   - reorder array to account for sliceomatic (as with many instrinsic matlab graphics functions) expects
%    the content of the array to be signal(y,x).

m=warning('off','MATLAB:divideByZero');     % turn off divide by zero messages, saving present state
signal = w.s
warning(m.state,'MATLAB:divideByZero');     % return to previous divide by zero message state


zmin = min(reshape(signal,1,prod(size(w.s))));
zmax = max(reshape(signal,1,prod(size(w.s))));

if zmin==zmax
    error ('ERROR: All intensity values are the same')
end
%signal(find(w.n==0)) = zmin;        % set undefined signal to lowest signal

signal = permute(signal,[2,1,3]);   % permute dimensions for sliceomatic

% Get titles and index of energy axis
[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (get(w));

% Plot data
colordef white; % white background
dp1 = (w.p1(end)-w.p1(1))/(length(w.p1)-1);
dp2 = (w.p2(end)-w.p2(1))/(length(w.p2)-1);
dp3 = (w.p3(end)-w.p3(1))/(length(w.p3)-1);
p1_cent_lims = [w.p1(1)+dp1/2, w.p1(end)-dp1/2];
p2_cent_lims = [w.p2(1)+dp2/2, w.p2(end)-dp2/2];
p3_cent_lims = [w.p3(1)+dp3/2, w.p3(end)-dp3/2];
sliceomatic(p1_cent_lims, p2_cent_lims, p3_cent_lims, signal, ...
    ['axis 1: ',w.label{w.pax(1)}], ['axis 2: ',w.label{w.pax(2)}], ['axis 3: ',w.label{w.pax(3)}],...
    title_pax{1}, title_pax{2}, title_pax{3}, [zmin,zmax]);
title(title_iax{1})
set(gca,'Position',[0.225,0.225,0.55,0.55]);
axis normal


