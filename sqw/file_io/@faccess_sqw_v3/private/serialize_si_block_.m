function [bytes,data_sz] = serialize_si_block_(obj,data,type)
% serialize an instrument or sample data block
%
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%

%type = class(data); % not yet a class or not always a class!
if isempty(data)
    bytes = [];
    data_sz = 0;
else
    form = obj.get_si_head_form(type);
    data_block = build_block_descriptor_(obj,data,type);
    bytes = obj.sqw_serializer_.serialize(data_block,form);
    %sz = obj.([type,'_pos_'])-obj.([type,'_head_pos_']);
    data_form = obj.get_si_form();
    if data_block.all_same
        if iscell(data)
            bytes2 = obj.sqw_serializer_.serialize(data{1},data_form);
        else
            bytes2 = obj.sqw_serializer_.serialize(data(1),data_form);
        end
    else
        bytes2 = obj.sqw_serializer_.serialize(data,data_form);
    end
    data_sz = numel(bytes2);
    bytes = [bytes',bytes2];
end

