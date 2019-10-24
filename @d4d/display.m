function display(w)
% Display sqw object to screen
%   >> display(w)

% Generic method to display array of objects. Needs specific private method display_single

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

class_name = class(w);
if isempty(w)
    disp(' ')
    disp([' Empty object of class ',class_name])
    disp(' ')
else
    if numel(w)==1
        display_single(w)
    else
        sz = size(w);
        str = '[';
        for i=1:length(sz),
            str = [str,num2str(sz(i)),'x'];   % size along each of the display axes
        end
        str(end)=']';
        disp(' ')
        disp([' ',str,' array of objects of class ',class_name])
        disp(' ')
    end
end
