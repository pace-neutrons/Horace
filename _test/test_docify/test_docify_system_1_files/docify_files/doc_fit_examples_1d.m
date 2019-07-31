% EXAMPLES:
% =========
%
% Fit a Gaussian on a linear background:
%
<MAIN:>
%   >> pin=[20,10,3];   % Initial height, position and standard deviation 
%   >> bg=[2,0]         % Initial intercept and gradient of background 
%   >> [yfit,fitpar]=fit(x,y,e,@gauss,pin,@linear_bg,bg) 
% 
% Remove a portion of the data, and give copious output during the fitting 
% 
%   >> [yfit,fitpar]=fit(x,y,e,@gauss,pin,@linear_bg,bg,'remove',[12,14],'list',2) 
% 
% Fix the position and constrain the width to be a constant multiple of 
% the constant part of the linear background: 
% 
%   >> [yfit,fitpar]=fit(x,y,e,@gauss,pin,[1,0,1],{3,1,1},@linear_bg,bg) 
<MAIN/END:>
<METHOD:>
%   >> pin=[20,10,3];   % Initial height, position and standard deviation 
%   >> bg=[2,0]         % Initial intercept and gradient of background 
%   >> [yfit,fitpar]=fit(w,@gauss,pin,@linear_bg,bg) 
% 
% Remove a portion of the data, and give copious output during the fitting 
% 
%   >> [yfit,fitpar]=fit(w,@gauss,pin,@linear_bg,bg,'remove',[12,14],'list',2) 
% 
% Fix the position and constrain the width to be a constant multiple of 
% the constant part of the linear background: 
% 
%   >> [yfit,fitpar]=fit(w,@gauss,pin,[1,0,1],{3,1,1},@linear_bg,bg) 
<METHOD/END:>
