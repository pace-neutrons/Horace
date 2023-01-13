function   obj = put_headers(obj,varargin)
% put or replace whole experiment info in a binary sqw file v4

%
%Usage:
%>>obj.put_header();
%>>obj.put_headers(header_num);
%>>obj.put_headers('-update');

%>>obj.put_header(___,sqw_obj_new_source_for_update)
%
% If update options is selected, header have to exist. This option replaces
% only constant header's information
%
%

% Ignore input arumnets, possibly provided from previous interface
[ok,mess,~,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:put_headers:invalid_argument',mess);
end
numarg = arrayfun(@(x)isnumeric(x),argi);
if any(numarg)
    argi = argi(~numarg);
end
%
obj = obj.put_block_data('bl_experiment_info_instruments',argi{:});
obj = obj.put_block_data('bl_experiment_info_samples');
obj = obj.put_block_data('bl_experiment_info_expdata');
