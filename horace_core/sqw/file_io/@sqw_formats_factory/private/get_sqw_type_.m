function [in_type,orig_type] = get_sqw_type_(in_obj)
% Determine the type of sqw object based on data in the header
% return value options are:
%      in_type == 'none' - the header is empty, there is no efix/emode
%                          data to determine the type
%      in_type == 'sqw2' - the header has emode==2 and
%                          numel(efix)>1
%      in_type == 'sqw'  - none of the above so using the
%                          class of obj i.e. sqw
orig_type = class(in_obj);
if isa(in_obj,'sqw')
    in_type = 'sqw';
    header =in_obj.experiment_info;
    if isa(header, 'Experiment')
        if isempty(header.expdata)
            in_type = 'none';
            return;
        else
            header = header.expdata(1);
        end
    elseif isempty(header)
        in_type = 'none';
        return;
    end
    emode = header.emode;
    if emode == 2
        nefix = numel(header.efix);
        if nefix>1
            in_type = 'sqw2';
        end
    end
else
    in_type = orig_type;
end
