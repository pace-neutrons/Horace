% EXAMPLES: 
% =========
%
% Fit a 2D Gaussian, allowing only height and position to vary: 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], [1,1,1,0,0,0]) 
% 
% Allow all parameters to vary, but remove two rectangles from the data 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ... 
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3]) 
% 
% The same, with a planar background: 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> const=0; dfdx=0; dfdy=0; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ... 
%                             @planar_bg, [const,dfdx,dfdy],... 
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3]) 
