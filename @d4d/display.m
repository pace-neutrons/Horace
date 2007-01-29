function display (w)
% DISPLAY Command window display of a 4D dataset
%
% Syntax:
%   >> display (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% If array of d4d
if (max(size(w))>1)
    if (length(size(w))<=2)
        disp(['           [',num2str(size(w,1)),'x',num2str(size(w,2)),' dataset_4D]'])
    else
        disp(['           [',num2str(length(size(w))),'-dimensional array of dataset_4D]'])
    end
    disp(' ')
    return
end

dnd_display(get(w));  % get a structure with the same fields as w
