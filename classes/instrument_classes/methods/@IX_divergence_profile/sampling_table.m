function [A,val]=sampling_table(obj,step)
% Create lookup table from which to create random sampling of divergence profile
%
%   >> a=sampling_table(obj)    	% table with default number of points
%   >> a=sampling_table(obj,step)   % table has specified number of points (npnt>=2)
%
% Use the output to generate random sampling as follows:
%   >> A_ran = rand(1000,50000);
%   >> x_ran = interp1(A,val,A_ran,'pchip','extrap');
%
% Input:
% -------
%   obj     IX_divergence_profile object
%   step    Define the graininess of the lookup table; [npnt, ndiv]
%               npnt    Minimum number of points (at least 4)
%               ndiv    How much finer to divide an interval at the minimum
%           Default: [500,10]
%           If one of the numbers is set to 0 or NaN then the default is used
%          for the corresponding parameter
%
% Output:
% -------
%   A       Cumulative probability distribution function (pdf) (column vector)
%   val     Values of independent variable of the pdf at the values of the
%          cumulative pdf (column vector)


if ~isscalar(obj), error('Function only takes a scalar object'), end

if nargin==2
    [A,val]=sampling_table(obj.angle,obj.profile);
else
    [A,val]=sampling_table(obj.angle,obj.profile,step);
end
