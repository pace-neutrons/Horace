function [samp,obj]  = get_sample(obj,varargin)
% return samples container stored in file or some part of
% this container, containing particular sample
% Usage:
%>>inst = obj.get_sample() % Returns first unique sample,
%         present in the file
%>>inst = obj.get_sample(number) % Returns sample with
%         number, specified as input.
%>>inst = obj.get_sample('-all') % Returns
%         unique object container with all samples stored
%         in the file
%NOTE:
% The sample number corresponds to the header number. 
% TODO: Clarify, % should it be run_id?
%
[argi,samp_number] = parse_get_inst_sample_arg_(obj,varargin{:});
[samp,obj] = obj.get_block_data('bl_experiment_info_samples',argi{:});
if ~isinf(samp_number)
    samp = samp(samp_number);
end
