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
            bytes{i} = fmt.bytes_from_field(struc);
        else
            bytes{i} = fmt.bytes_from_field(val);
        end
    else
        if ischar(val)
            % strings have length written in the beginning
            bytes{i} = [typecast(uint32(numel(val)),'uint8'),uint8(val)];
        elseif iscell(val)
            tBytes = cell(1,numel(val));
            for j=1:numel(val)
                tBytes{j} = serialize_(obj,val{j})';
            end
            bytes{i} = [tBytes{:}];
            
        else
            type  = class(val);
            ftype = class(fmt);
            if ~strcmp(type,ftype)
                type = ftype;
                val = feval(ftype,val);
            end
            is = obj.class_map_.isKey(type);
            if is
                nel = numel(val);
                fnel = prod(fmt);
                if nel ~= fnel
                    error('STRUCT_SERIALIZER:invalid_argument',...
                        'format string for constant field %s contains %d elements but field itself has %d elements',...
                        field_n,fnel,nel)
                end
                if nel >1
                    val = reshape(val,1,nel);
                end
                bytes{i} = typecast(val,'uint8');
            else % can it be structure?
                if isstruct(val)
                    bytes{i} = serialize_(obj,val)';
                else
                    error('STRUCT_SERIALIZER:invalid_argument',...
                        'Unsupported type for: field %s, type: %s',...
                        field_n ,type)
                end
            end
        end
    end
end
bytes = [bytes{:}]';

