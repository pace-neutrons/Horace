function [n_inputs,ldrs,sqw_obj,wout] = init_sqw_obj_from_file_for_sqw_op_(win)
% method parses input cellarray of files/sqw objects or single file
% and conters it into the form, acceptable for sqw_op/sqw_op_bin_pixels
% functions
% 
% Input:
% win   -- filename of sqw object or cellarray of filenames or sqw objects 
%          which are the source of sqw_op() operation
%
% Returns:
% n_inputs -- number of input objects which are the sources of operation.
% ldrs     -- cellarray of loaders to load each input object or input objects
%             themselves if input cellarray contains input objects
% sqw_obj  -- logical array containing true if input element in win is sqw
%             object and false if it is filename.
% wout     -- array of empty output sqw objects, to be used as the
%             resulting array for operation.
%  

if ~iscell(win)
    win = {win};
end
n_inputs = numel(win);

ldrs = cell(size(win));
sqw_obj = false(size(win));
for i=1:n_inputs
    if istext(win{i})
        ldrs{i} = sqw_formats_factory.instance.get_loader(win{i});
        if ~ldrs{i}.sqw_type
            error('HORACE:algorithms:invalid_argument', ...
                'input file N:%d with name %s is not an sqw-type file', ...
                i,win{i});
        end
    elseif isa(win{i},'sqw')
        sqw_obj(i) = true;
        ldrs{i} = win{i};
    else
        error('HORACE:algorithms:invalid_argument', ...
            'Input object N:%d is not an sqw object. Its class is: %s',...
            i,class(win{i}));
    end
end
if nargout>0
    wout = repmat(sqw(),size(win));
end
end