% EXAMPLES:
% =========
%
% Fit a Gaussian on a linear background to two data sets:
%
<MAIN:>
% If the data is in arrays x,y,e arrays, then package data into an array of
% structures with fields x,y,e:
%   >> w=struct('x',x1,'y',y1,'e',e1);      % x1,y1,e1 contain first data set 
%   >> w(2)=struct('x',x2,'y',y2,'e',e2);   % x2,y2,e2 contain 2nd data set 
%
<MAIN/END:>
% Fit a global Gaussian, with independent linear backgrounds which have the
% same starting parameters:
%
%   >> pin=[20,10,3];   % Initial height, position and standard deviation
%   >> bg=[2,0]         % Initial intercept and gradient of background
%   >> [wfit,fitpar]=<func_prefix><func_suffix>(w,@gauss,pin,@linear_bg,bg)
%
% Remove a portion of the data, and give copious output during the fitting
% - remove a common range:
%   >> [wfit,fitpar]=<func_prefix><func_suffix>(w,@gauss,pin,@linear_bg,bg,'remove',...
%                                             [12,14],'list',2)
% - remove different ranges for the two data sets:
%   >> [wfit,fitpar]=<func_prefix><func_suffix>(w,@gauss,pin,@linear_bg,bg,'remove',...
%                                             {[12,14],[10,13]},'list',2)
%
% Fix the position and constrain (1) the constant part of the background
% of the first data set to be a fixed multiple of the width of the Gaussian,
% and (2) the gradient of the background to the second data set to be
% a fixed multiple of the height of the Gaussian:
%
%   >> [wfit,fitpar]=<func_prefix><func_suffix>(w,@gauss,pin,[1,0,1],@linear_bg,bg,...
%                             {{1,3,-1},{2,1,-1,1e-3}})
%
% Fit independent Gaussians but which are constrained to have the same
% widths
%
%   >> [wfit,fitpar]=<func_prefix><func_suffix>(w,@gauss,pin,{{},{3,3,1}},@linear_bg,bg,...
%                                         'local_foreground')
