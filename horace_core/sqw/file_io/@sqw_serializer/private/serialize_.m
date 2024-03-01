function bytes = serialize_(obj,struc,format)
% serialize structue into the form, usually used by Horace
%


if isa(format,'sqw_field_format_interface')
    bytes = format.bytes_from_field(struc);
    return;
end

fn = fieldnames(format);
bytes = cell(1,numel(fn));
%
for i=1:numel(fn)
    field_n = fn{i};
    fmt = format.(field_n);
    if ~isa(fmt,'iVirt_field')
        val = struc.(field_n);
    else
        val = [];
    end
    if isa(fmt,'sqw_field_format_interface')
        if isa(fmt,'iVirt_field')
            ser_field = fmt.bytes_from_field(struc);
        else
            ser_field = fmt.bytes_from_field(val);
        end
    else
        if ischar(val)
            % strings have length written in the beginning
            ser_field = [typecast(uint32(numel(val)),'uint8'),uint8(val)];
        elseif iscell(val)
            tBytes = cell(1,numel(val));
            for j=1:numel(val)
                tBytes{j} = serialize_(obj,val{j})';
            end
            ser_field = [tBytes{:}];
            
        else % convert according to known exisiting format definitions
            type  = class(val);
            ftype = class(fmt);
            if ~strcmp(type,ftype)
                type = ftype;
                val = feval(ftype,val);
            end
            is = obj.class_map_.isKey(type);
            if is
                % number of elements in the converted value
                nel = numel(val);
                % number of elements format expects
                fnel = prod(double(fmt));
                if nel ~= fnel
                    error('STRUCT_SERIALIZER:invalid_argument',...
                        'format string for constant field %s contains %d elements but field itself has %d elements',...
                        field_n,fnel,nel)
                end
                if nel >1
                    val = reshape(val,1,nel);
                end
                ser_field = typecast(val,'uint8');
            else % can it be structure?
                if isstruct(val)
                    ser_field = serialize_(obj,val)';
                else
                    error('STRUCT_SERIALIZER:invalid_argument',...
                        'Unsupported type for: field %s, type: %s',...
                        field_n ,type)
                end
            end
        end
    end
    bytes{i}= ser_field(:)';
end
bytes = [bytes{:}]';

