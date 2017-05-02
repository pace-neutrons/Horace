% EXAMPLES:
% =========
%
% Fit a global 2D Gaussian to an array of data sets, allowing only height and
% position to vary: 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], [1,1,1,0,0,0]) 
% 
% Allow all parameters to vary, but remove two rectangles from the data
% and give copious output during the fitting
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> [wout, fdata] = fit(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ... 
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3],'list',2) 
% 
% Allow independent planar backgrounds for every object: 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> const=0; dfdx=0; dfdy=0; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ... 
%                                  @planar_bg, [const,dfdx,dfdy]) 
% 
% Suppose there are two objects in the array. Constrain the constant 
% of the planar background for the first data set to be a fixed multiple 
% of the Gaussian height, and for the second a fixed multiple of the 
% Gaussian width: 
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> const=0; dfdx=0; dfdy=0; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ... 
%                                  @planar_bg, [const,dfdx,dfdy],... 
%                             {{1,1,-1,1e-2},{1,3,-1,0.1}})
%
% Allow independent 2D Gaussians for the two data sets, but which are
% constrained to have the same widths
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5; 
%   >> const=0; dfdx=0; dfdy=0; 
%   >> [wout, fdata] = <func_prefix><func_suffix>(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ...
%                                  {{},{{4,4,1},{5,5,1},{6,6,1}}}
%                                  @planar_bg, [const,dfdx,dfdy]...
%                                           'local_foreground')
