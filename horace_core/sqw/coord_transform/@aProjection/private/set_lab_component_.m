function obj = set_lab_component_(obj,num_comp,val)
% Check and set up the n-th element of the label's cellarray
if ~istext(val)
    error('HORACE:aProjection:invalid_argument',...
        'Label component N%d has to be a string. It is %s',num_comp, ...
        disp2str(val));
end
if isempty(obj.label_)
    obj.label_ = cell(1,4);
end
obj.label_{num_comp}= val;