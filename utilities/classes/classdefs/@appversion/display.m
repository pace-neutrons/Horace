function display(w)
% Display object to screen
%   >> display(w)

% Generic method to display array of objects. Needs specific private method display_single

% Original author: T.G.Perring
%
% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)

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
