function [exper,obj]  = get_exp_info(obj,varargin)
% Get full data header or headers for sqw file written in format v3
%
% If instrument and sample are present in the file (not the empty
% structures) it loads instruments and samples from the file and attaches
% them to the header(s)
%
% Usage:
%>>exp_info = obj.get_exp_info();       -- get header number 1
%>>exp_info = obj.get_exp_info(1);      -- get header number 1
%>>exp_info = obj.get_exp_info(number); -- get header with specified number
%>>exp_info = obj.get_exp_info(numbers);-- where numbers are array of numbers
%                                          return headers with these numbers
% 
%>>exp_info = obj.get_exp_info('-all');
%>>exp_info = obj.get_exp_info('-no_samp_inst'); % do not set up sample and instrument to header
%                    even if they are defined in the file, except the basic sample and inst,
%                    defined in version 2
%
% First three forms return single header, first two return header number 1.

%NOTE:
% The sample number corresponds to the header number. 
% TODO: Clarify, % should it be run_id?
%
[argi,samp_inst_number] = parse_get_inst_sample_arg_(obj,varargin{:});
% after that, the only parameters may 
[ok,mess,no_isamp_inst,argi]= parse_char_options(argi,{'-no_sampinst'});
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument',mess);
end
% at this stage, arguments can only describe initialization
[obj,exp_data] = obj.get_sqw_block('bl_experiment_info_expdata',argi{:});
if no_isamp_inst
    if ~isinf(samp_inst_number)
        exp_data = exp_data(samp_inst_number);
    end    
    exper = Experiment([],IX_null_inst(),IX_null_sample,exp_data);
    return;
end
[obj,Inst] = obj.get_sqw_block('bl_experiment_info_instruments');
[obj,samp] = obj.get_sqw_block('bl_experiment_info_samples');

if ~isinf(samp_inst_number)
    exp_data = exp_data(samp_inst_number);
    Inst =     Inst(samp_inst_number);
    samp =     samp(samp_inst_number);
end
exper    = Experiment([],Inst,samp,exp_data);