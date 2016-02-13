function fl_cell_array=flatten_cell_array(the_celarray)
% function convert multilever cell array containing cellarrays of
% cellarrays into cellarray, containing objects.
% empty cells are dropped from output array

if iscell(the_celarray)
    nobj=0;
    nobj = count_obj(the_celarray,nobj);
    fl_cell_array = cell(nobj,1);
    nobj = 0;
    fl_cell_array  = flatten(the_celarray,fl_cell_array,nobj );
else
    fl_cell_array = {the_celarray};
end


function nobj = count_obj(the_array,nobj)
% count objects which are not cellarrays
for i=1:numel(the_array)
    if iscell(the_array{i})
        if ~isempty(the_array{i})
            nobj= count_obj(the_array{i},nobj);
        end
    else
        if ~isempty(the_array{i})
            nobj=nobj+1;
        end
    end
end

function [fl_cell_array,nobj] = flatten(the_array,fl_cell_array,nobj)
% copy objects to flat cell-array
for i=1:numel(the_array)
    if iscell(the_array{i})
        if ~isempty(the_array{i})
            [fl_cell_array,nobj] = flatten(the_array{i},fl_cell_array,nobj);
        end
    else
        if ~isempty(the_array{i})
            nobj=nobj+1;
            fl_cell_array{nobj} = the_array{i};
        end
    end
end
