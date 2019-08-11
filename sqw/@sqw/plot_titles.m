function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = plot_titles (w)
% Get titling and caption information for an sqw object
%
% Syntax:
%   >> [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = plot_titles (w)
% 
% Input:
% ------
%   data            Structure for which titles are to be created from the data in its fields.
%                   Type >> help check_sqw_data for a full description of the fields
%
% Output:
% -------
%   title_main      Main title (cell array of character strings)
%   title_pax       Cell array containing axes annotations for each of the plot axes
%   title_iax       Cell array containing annotations for each of the integration axes
%   display_pax     Cell array containing axes annotations for each of the plot axes suitable 
%                  for printing to the screen
%   display_iax     Cell array containing axes annotations for each of the integration axes suitable 
%                  for printing to the screen
%   energy_axis     The index of the column in the 4x4 matrix din.u that corresponds
%                  to the energy axis

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

% This routine invented solely for the convenience of interface to sliceomatic, which cannot
% see the sqw private function data_plot_titles

[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles (w.data);
