function  [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
    data_plot_titles(obj)
%

% Get titling and caption information for an sqw data structure
%
% Syntax:
%   >> [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = data_plot_titles (data)
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
% $Revision: 1466 $ ($Date: 2017-04-05 12:27:52 +0100 (Wed, 05 Apr 2017) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


fname = fullfile(obj.filepath,obj.filename);
[title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = ...
    obj.data_plot_titles(fname);

