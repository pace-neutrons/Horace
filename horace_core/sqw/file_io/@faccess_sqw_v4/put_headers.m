function   obj = put_headers(obj,varargin)
% put or replace whole experiment info in a binary sqw file v4

%
%Usage:
%>>obj.put_header();
%>>obj.put_headers(header_num);
%>>obj.put_headers('-update'); %-- redundant property, not used any more
%>>obj.put_headers('-no_sampinst'); % do not store instrument or sample

%>>obj.put_header(___,new_source_for_update)
%      where new_source_for_update could be modified sqw object or Experiment
%
% To work correctly, the file accessor have to be initialized by correct sqw v4 file
%
% Theoretically, it can be initialized on the fly if the input file is
% provided but this mode have not been tested.
%

% Ignore input arguments, possibly left from previous interface
[ok,mess,~,no_samp_inst,argi] = parse_char_options(varargin,{'-update','-no_sampinst'});
if ~ok
    error('HORACE:put_headers:invalid_argument',mess);
end
numarg = arrayfun(@(x)isnumeric(x),argi);
if any(numarg)
    argi = argi(~numarg);
end
head_provided = cellfun(@(x)(isa(x,'Experiment')||isa(x,'sqw')||is_sqw_struct(x)), ...
    argi);
if any(head_provided)
    obj.sqw_holder_ = argi{head_provided};
    argi = argi(~head_provided);
end
%
if ~no_samp_inst
    obj = obj.put_block_data('bl_experiment_info_instruments',argi{:});
    obj = obj.put_block_data('bl_experiment_info_samples');
end
obj = obj.put_block_data('bl_experiment_info_expdata');
