function [targ_str,pos] = deserialize_bytes_(obj,bytes,template_str,varargin)
% Convert sequence of bytes into structure, using template_str structure
% as template to obtain data types and sizes
%
%Usage:
%>>[target_str,pos] = deserialize_bytes_(obj,bytes,template_str);
%>>[target_str,pos] = deserialize_bytes_(obj,bytes,template_str,start_pos);
%
%where:
%  bytes -- sequence of bytes to convert into the structure
%  template_str -- the structure, used as template to convert sequence of
%                   bytes into target structure. Simple fields of this
%                   structure used to identify the output according to a
%                   simple rule:
%                   the field name of the templated structure defined the
%                   field name of the target structure and the size and the
%                   type of the templated strucute field define size and
%                   the type of the bytes
%                   Complex fields of the templated structure are converted
%                   according to the rules described by sqw_field_format_interface
%                   classes.
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%

if nargin==3
    pos = 1;
else
    pos = varargin{1};
end

if isa(template_str,'sqw_field_format_interface')  % field has special convertor
   [targ_str,length] = template_str.field_from_bytes(bytes,pos);
   pos = pos+length;
   return;
end


fn = fieldnames(template_str);
targ_str = struct();
%
%
for i=1:numel(fn)
    field = fn{i};
    fmt = template_str.(field);
    if isa(fmt,'sqw_field_format_interface')  % field has special convertor
        % 1)---------------------------------------------------------------
        if isa(fmt,'field_const_array_dependent')
            fmt.host = template_str;
        end
        [res,length] = fmt.field_from_bytes(bytes,pos);
        pos = pos+length;
        
        if isa(fmt,'iVirt_field')
            fmt.field_value = res;
            template_str.(field) = fmt;
            continue
        end
        % 2)---------------------------------------------------------------
    elseif ischar(fmt) % strings are always converted into standard form
        length = double(typecast(bytes(pos:pos+4-1),'int32'));
        pos = pos+4;
        if length == 0
            res = '';
        else
            res = char(bytes(pos:pos+length-1))';
        end
        pos = pos+length;
        % 3)---------------------------------------------------------------
    else % fixed size field defined by their format string
        type = class(fmt);
        is = obj.class_map_.isKey(type);
        if is
            length = obj.class_map_(type);
            nel = prod(double(fmt));
            if nel > 1
                length= length*nel;
                sz = double(fmt);
                res = reshape(typecast(bytes(pos:pos+length-1),type),sz(:)');
            else
                res = typecast(bytes(pos:pos+length-1),type);
            end
            pos = pos+length;
        else % can it be a structure or custom formatter?
            % 4)-----------------------------------------------------------
            if isstruct(fmt)
                [res,pos] = deserialize_bytes_(obj,bytes,fmt,pos);
            else
                error('STRUCT_SERIZLIZER:unsupported_data_type',...
                    'Unsupported type for: field %s, type: %s',...
                    fn{i},type)
            end
        end
    end
    targ_str.(field) = res;
end

