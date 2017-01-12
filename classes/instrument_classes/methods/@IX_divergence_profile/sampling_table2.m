function [xtab,cumpdf]=sampling_table2(obj,varargin)
% Create lookup table from which to create random sampling of divergence profile
%
%   >> [xtab,cumpdf]=sampling_table2(obj)    	 % table with default number of points
%   >> [xtab,cumpdf]=sampling_table2(obj,step)   % table has specified number of points
%
% Differs from sampling_table in that cumpdf is not assumed to correspond to
% equally spaced intervals between 0 and 1.
%
% Use the output to generate random sampling as follows:
%   >> cumpdf_ran = rand(1000,50000);
%   >> X = interp1(cumpdf,xtab,cumpdf_ran,'pchip','extrap');
%
% or use the utility function rand_cumpdf2:
%   >> X = rand_cumpdf2 (xtab, cumpdf,...)
%
% Input:
% -------
%   obj     IX_divergence_profile object
%   step    Define the graininess of the lookup table
%               npnt            Divide the range of x into npnt equally spaced
%                              values
%               [npnt, ndiv]    Divide each interval such that:
%                   npnt    Minimum number of points (at least 4)
%                   ndiv    How much finer to divide an interval at the minimum
%                               Default: [500,10]
%                               If one of the numbers is set to 0 or NaN then
%                              the default is used for the corresponding parameter
%               xtab            Explicitly give the output values
%
% Output:
% -------
%   xtab    Values of independent variable of the pdf at the values of the
%          cumulative pdf (column vector)
%   cumpdf  Cumulative probability distribution function (pdf) (column vector)


if ~isscalar(obj), error('Function only takes a scalar object'), end

[xtab,cumpdf]=sampling_table2(obj.angle,obj.profile,varargin{:});
