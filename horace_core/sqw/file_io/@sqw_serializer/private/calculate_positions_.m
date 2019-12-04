function [size_str,pos,err,template_struc] = calculate_positions_(obj,template_struc,input,pos)
% calculate the positions, the fields of the input templated_structure
% occupy in an input or outpupt data file.
%
% pos at the end -- the final position
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
err = false;
size_str= struct('start_pos_',pos);

if isa(template_struc,'sqw_field_format_interface') % field has special convertor
    if obj.input_is_stuct_
        length = template_struc.size_of_field(input);
    else
        [length,template_struc,err]  = template_struc.field_size(input,pos);
        if err
            size_str.eof_pos_ = pos;
            return;
        end
    end
    pos = pos+length;
    return;
end

%
fn = fieldnames(template_struc);
%
for i=1:numel(fn)
    field = fn{i};
    fmt = template_struc.(field);
    field_name = [field,'_pos_'];
    size_str.(field_name) = pos;
    %
    if isa(fmt,'sqw_field_format_interface') % field has special convertor
        % 1)---------------------------------------------------------------
        if obj.input_is_stuct_
            if isa(fmt,'iVirt_field')
                length = fmt.size_of_field(input);
            else
                val = input.(field);
                length = fmt.size_of_field(val);
            end
        else
            if isa(fmt,'field_const_array_dependent')
                fmt.host = template_struc;
            end
            [length,fmt,err]  = fmt.field_size(input,pos);
            if err
                size_str.eof_pos_ = pos;
                return;
            end
            if isa(fmt,'iVirt_field')
                template_struc.(field) = fmt;
            end
        end
    elseif ischar(fmt) % strings are always converted into standard form
        % 2)---------------------------------------------------------------
        if obj.input_is_stuct_
            val = input.(field);
            sz = numel(val);
        else
            [sz,err]= get_size(obj,input,pos);
            if err
                size_str.eof_pos_ = pos;
                return;
            end
            %
        end
        length =obj.class_map_('uint32')+sz;
    else % fixed size field defined by their format string
        % 3)---------------------------------------------------------------
        type = class(fmt);
        is = obj.class_map_.isKey(type);
        if is
            length = obj.class_map_(type);
            nel =  prod(double(fmt));
            if nel>1
                length= length*nel;
            end
        else % can it be a structure or custom formatter?
            % 4)-----------------------------------------------------------
            if isstruct(fmt)
                length = 0;
                [size_str.(field_name),pos,err] = calculate_positions_(obj,fmt,input,pos);
                if err
                    size_str.eof_pos_ = pos;
                    return;
                end
            else
                %val = struct(val);
                %[size_str,pos] = calculate_positions_(obj,val,input,pos);
                error('STRUCT_SERIALIZER:unsupported_data_type',...
                    'Unsupported type for: field %s, type: %s',...
                    field,type)
            end
        end
    end % end datatypes
    %
    pos = pos+length;
    
    eof_reached = check_if_eof(obj,pos);
    if eof_reached
        pos = pos - length;
        size_str.eof_pos_ = pos;
        err = true;
        break
    end
    
end

function is = check_if_eof(obj,pos)
if pos>obj.eof_pos_
    is = true;
else
    is = false;
end



function [sz,err] = get_size(obj,input,pos)


err = false;
if obj.input_is_file_  %file stream
    fseek(input,pos,'bof');
    [~,res] = ferror(input);
    if res ~= 0
        sz = inf;
        err = true;
        return;
    end
    
    sz = fread(input,1,'uint32');
    [~,res] = ferror(input);
    if res ~= 0
        err = true;
        return;
    end
else  % bytes
    sz = double(typecast(input(pos:pos+4-1),'uint32'));
end
