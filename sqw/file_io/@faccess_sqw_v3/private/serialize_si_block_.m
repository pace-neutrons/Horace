function [bytes,data_sz] = serialize_si_block_(obj,data,type)
% serialize an instrument or sample data block
%
%type = class(data); % not yet a class or not always a class!
if isempty(data)
    bytes = [];
    data_sz = 0;
else
    form = obj.get_si_head_form(type);
    data_block = build_block_descriptor_(obj,data,type);
    bytes = obj.sqw_serializer_.serialize(data_block,form);
    sz = obj.([type,'_pos_'])-obj.([type,'_head_pos_']);
    if numel(bytes) ~= sz
        error('FACCESS_SQW_V3:runtime_error',...
            ' size of serialized %s header %d different from calculated value %d',...
            type,numel(bytes),sz);
    end
    
    data_form = obj.get_si_form();
    if data_block.all_same
        if iscell(data)
           bytes2 = obj.sqw_serializer_.serialize(data{1},data_form);            
        else
           bytes2 = obj.sqw_serializer_.serialize(data(1),data_form);
        end
    else
        bytes2 = obj.sqw_serializer_.calculate_positions(data,data_form);
    end
    data_sz = numel(bytes2);
    bytes = [bytes',bytes2];
end

