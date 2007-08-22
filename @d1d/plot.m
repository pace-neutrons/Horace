function plot(w,varargin)
% Draws a plot of line, markers and error bars for a 1D dataset
%
% Syntax:
%   >> plot(w)
%   >> plot(w,xlo,xhi)
%   >> plot(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> plot(w,...,fig_name)       % draw with name = fig_name
%
% [Note: equivalent to the plot function 'dd'; included for naming consistency
% with corresponding plot function for two and three dimensional datasets]


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

dd(w,varargin)
