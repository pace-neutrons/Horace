function display (w)
% DISPLAY Command window display of a 1D dataset
%
% Syntax:
%   >> display (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% If array of d1d
if (max(size(w))>1)
    if (length(size(w))<=2)
        disp(['           [',num2str(size(w,1)),'x',num2str(size(w,2)),' dataset_1D]'])
    else
        disp(['           [',num2str(length(size(w))),'-dimensional array of dataset_1D]'])
    end
    disp(' ')
    return
end

dnd_display(get(w));  % get a structure with the same fields as w
