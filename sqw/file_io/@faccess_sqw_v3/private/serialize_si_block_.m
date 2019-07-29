function [bytes,data_sz] = serialize_si_block_(obj,data,type)
% serialize an instrument or sample data block
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%

%type = class(data); % not yet a class or not always a class!
if isempty(data)
    bytes = [];
    data_sz = 0;
else
    % new instrument:
    % get format used to convert data into bytes
    
    % obtain formatter, to use for the instrument or sample header.
    form = obj.get_si_head_form(type);
    % build block descriptor, to describe common sample/instrument block
    % containing the information about stored innstrument/sample version
    data_block = build_block_descriptor_(obj,data,type);
    % Currently we have format of sample and instrument as of version 2,
    % despite the format of the information block is still of version 1;
    data_block.version = uint32(2);
    % convert this information into bytes
    bytes = obj.sqw_serializer_.serialize(data_block,form);
    %sz = obj.([type,'_pos_'])-obj.([type,'_head_pos_']);
    %
    % get the format of sample or instrument:
    
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
    bytes = [bytes;bytes2'];
end

