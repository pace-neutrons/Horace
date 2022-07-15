function wout = dnd (win,varargin)
% Convert input sqw object, array of sqw objects or cellarray of sqw objects
% into corresponding d0d, d1d,...d4d object(s)
%
%   >> wout = dnd (win)
%   >> wout = dnd (win,''-cell_return')
%
%  If the inputs are convertable to the same shape of dnd objects (e.g. all
%  d1d or all d3d), the function return the array of extracted objects
%  If the inputs correspond to the mixture of dnd objects (e.g. d1d and d2d),
%  the result is the cellarray containing these objects
%
% if '-cell_return' option is provided, the method returns cellarray of dnd
% objects in any case
%
%==========================================================================
% TODO: make input the filenames list?
%
[ok,mess,cell_return]  = parse_char_options(varargin,{'-cell_return'});
if ~ok
    error('HORACE:dnd:invalid_argument',mess);
end

wout = cell(size(win));
if iscell(win)
    cell_input = true;
    if ~isa(win{1},'sqw')
        error('HORACE:dnd:invalid_argument',...
            'input for dnd operation can be array or cellarray of sqw objects')
    end
    cl_name = class(win{1}.data);
else
    cell_input = false;
    if ~isa(win(1),'sqw')
        error('HORACE:dnd:invalid_argument',...
            'input for dnd operation can be array or cellarray of sqw objects')
    end

    cl_name = class(win(1).data);

end
same_type = false(size(win));

for i=1:numel(win)
    if cell_input
        wout{i} = DnDBase.dnd(win{i});
    else
        wout{i} = DnDBase.dnd(win(i));
    end
    if isa(wout{i},cl_name)
        same_type(i) = true;
    end
end
if ~cell_return && all(same_type)
    wout = [wout{:}];
end

