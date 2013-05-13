function [wout,single_data_arg,cell_data,xye,xye_xarray] = repackage_output_datasets(wout)

% [ok,mess,w,single_data_arg,cell_data,xye,xye_xarray] = repackage_input_datasets(args{1:iarg_fore_func-1});

% Turn output data into form of input data
if single_data_arg
    % Convert x coordinates back to array, if xye triple and songle array input
    % *** could make more efficient if for options.selected=false just pick up the input x coordinates
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
    % Convert output to array, if input wa array
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
