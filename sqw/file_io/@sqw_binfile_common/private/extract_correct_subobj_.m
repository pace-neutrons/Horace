function [subobj,new_subobj] = extract_correct_subobj_(obj,obj_name,varargin)
% Extract a subobject, requested for save or upgrade operations, using
% various input arguments combinations
%
%
new_subobj = false;
if ~isempty(varargin)
    input_obj = varargin{1};
    if isa(input_obj,'sqw')
        subobj = input_obj.(obj_name);
    elseif isstruct
        subobj = varargin{1};
    else
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_detinfo: the routine accepts an sqw object and/or "-update" options only');
    end
    new_subobj = true;
else
    subobj = obj.sqw_holder_.(obj_name);
end


if ~isempty(argi)
    input_obj = argi{1};
    if isa(input_obj,'sqw')
        input_obj = input_obj.main_header;        
    elseif isstruct
        input_obj = argi{1};
    else
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_main_header: the routine accepts an sqw object and/or "-update" options only');
    end
    update = true;
else
    input_obj = obj.sqw_holder_.main_header;
end


if ~isempty(argi)
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),argi);
    unknown  = ~(sqw_pos||numeric_pos);
    if any(unknown)
        disp('unknown input: ',argi{unknown});
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_header: the routine accepts only sqw object "-update" and/or header number, got something as above');
    end
    input_obj = argi{sqw_pos};
    input_num = argi{numeric_pos};
    if ~isempty(input_obj)
        if isa(input_obj,'sqw')
            input_obj = input_obj.header;
        end
        update = true;
    else
        input_obj = obj.sqw_holder_.header;
    end
else
    input_obj = obj.sqw_holder_.header;
    input_num = [];
end