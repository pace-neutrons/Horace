function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
    data_plot_titles(obj,full_file_name)
%Get titling and caption information for an sqw data structure
% Input:
% ------
%   obj            The projection instance, containing all necessary
%                  information to build caption
%  full_file_name  the name of the file, related to projection. If present,
%                  the name of the file is added to the projection title.
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
if ~exist('full_file_name','var')
    full_file_name = [];
end

[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
    titles_calc_func_(obj,full_file_name);
end
