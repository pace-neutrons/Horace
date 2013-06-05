function wout = repackage_output_datasets(w, single_data_arg, cell_data, xye, xye_xarray)
% Repackage calculated data into the form of the input data. Is the inverse of repackage_input_datasets
%
%   >> wout = repackage_output_datasets(wout, single_data_arg, cell_data, xye, xye_xarray)
%
% Input:
% ------
%   w               Repackaged data: a cell array where each element w(i) is either
%                    - an x-y-e triple with w(i).x a cell array of arrays, one for each x-coordinate,
%                    - a scalar object
%
%   single_data_arg Logical scalar: true if originally a single input data argument, false if x,y,e
%
%   cell_data       Logical scalar: true if originally an input data was a cell array
%
%   xye             Logical array, size(w): indicating which data were originally
%                  x-y-e triples (true), or objects (false)
%
%   xye_xarray      Logical array, size(w): indicates that x values in x-y-e triples
%                  originally formed a single numeric array (true), or was a cell array
%                  with one element for each x-coordinate (false).
%                   Is set to false for data sets that are objects

wout=w;
if single_data_arg
    % Convert x coordinates back to array, if xye triple and single array input
    for i=1:numel(wout)
        if xye(i) && xye_xarray(i)
            nx=numel(wout{i}.x);   % is a cell array
            if nx>1
                wout{i}.x=squeeze(nx+1,cat(wout{i}.x{:}));
            else
                wout{i}.x=wout{i}.x{1};
            end
        end
    end
    % Convert output to array, if input was an array
    if ~cell_data
        if isstruct(wout{1})
            wout=cell2mat(wout);
        else
            wout=cell2mat_obj(wout);    % for some reason, cell2mat doesn't work with arbitrary objects, so fix-up
        end
    end
else
    wout=wout{1}.y;         % if x,y,e supplied as separate arguments, then just return y array.
end
