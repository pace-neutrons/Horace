function [set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj_list,varargin)
% Helper function for various set component for Tobyfit methods
% Given array of values to set on array of objects including filebased objects, identify how these
% values should be distributed among objects.

%Inputs:
% obj_or_facc -- celarray of sqw object or sqw object accessors
% varargin    -- celarray of various parameters to set
% Output:
% set_single  -- if true, varargin contains single value to set on all sqw
%               objects in the obj array
% set_per_obj
%             -- if true, varargin contains number of elements equal to number of
%               objects in the obj array
% if both set_single&set_per_obj are false, varargin contains the number of
%                objects equal to number of runs in all sqw objects from
%                the array. Throws "HORACE:sqw:invalid_argument"
%                if this is incorrect
% n_runs_in_obj
%            -- array containing number of runs in each sqw object in
%               the obj array if set_single == false. Empty if
%               set_single == true.

if ~isempty(varargin)
    if iscell(varargin) &&numel(varargin)> 1
        length_s = cellfun(@find_length,varargin);
        n_val_to_set = max(length_s);
    else
        n_val_to_set = find_length(varargin{1});
    end
else
    n_val_to_set = 1;
end

n_obj = numel(obj_list);
set_per_obj = false;
if n_val_to_set  == 1
    set_single = true;
    n_runs_in_obj = [];
else
    set_single = false;
    n_runs_in_obj = zeros(1,n_obj);
    for i=1:n_obj
        the_obj = obj_list{i};
        if isa(the_obj,'sqw')
            n_runs_in_obj(i) = the_obj.main_header.nfiles;
        elseif isa(the_obj,'sqw_file_interface')
            hdr = the_obj.get_main_header();
            n_runs_in_obj(i) = hdr.nfiles;
        else
            error('HORACE:algorithms:invalid_argument', ...
                'This method accepts the list of sqw objects and the class of object N%d in this list is %s (non-sqw type)', ...
                i,class(the_obj));
        end
    end
    if n_val_to_set  == n_obj
        set_per_obj = true;
    elseif n_val_to_set == sum(n_runs_in_obj)
        set_per_obj = false;
    else
        error('HORACE:sqw:invalid_argument',...
            ['An array of object to set values was given ', ...
                                    'but the length of values do not match the number of runs in ',...
            '(all) the sqw objects being altered'])
    end
end
%
function ml = find_length(x)
if ischar(x)||isstring(x)
    ml = 1;
else
    ml = numel(x);
end
