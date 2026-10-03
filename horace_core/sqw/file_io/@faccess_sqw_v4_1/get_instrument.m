function [inst,obj]  = get_instrument(obj,varargin)
% return instruments container stored in file or some part of
% this container, containing particular instrument
% Usage:
%>>inst = obj.get_instrument() % Returns first unique instrument,
%         present in the file
%>>inst = obj.get_instrument(number) % Returns instrument with
%         number, specified as input.
%>>inst = obj.get_instrument('-all') % Returns unique object
%         container with all instruments stored in the file
%NOTE:
% The instrument number (option 2) corresponds to the header number. 
% TODO: Clarify, should it be run_id?
%
[argi,instr_number] = parse_get_inst_sample_arg_(obj,varargin{:});
[inst,obj] = obj.get_block_data('bl_experiment_info_instruments',argi{:});
if ~isinf(instr_number)
    inst = inst(instr_number);
end

