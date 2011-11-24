function [keys,fields] = split_keys_nonkeys(keys_recognized,fields_recognized,varargin )
% function splits list of arguments in the form of
% {'-key1','parameter1','parameter2','-key2','parameter3'} into cellarray
% of keys and parameters and verifies that all keys belong to
% keys_recognized and fields -- to fields_recongized
%
%
% $Author: Alex Buts 20/10/2011
% 
% 
% $Revision:  $ ($Date:  $)
%
% possible modifiers of the data format
% are there any modyfiers (keys) among the input parameters?
keys_list=cellfun(@is_key,varargin);
keys     = cell(1,sum(keys_list));
keys(:)  = varargin(keys_list);
if ~all(ismember(keys,keys_recognized))
    unknown_keys= ~ismember(keys,keys_recognized);
    fprintf('ERROR: ->found unknown key: %s\n',keys{unknown_keys});
    error('RUNDATA:invalid_arguments','unknown keys provided as input parameters');
end

% what is actually defined by this class instance:
% (should be only public fiedls but currenly works with all)

non_keys              = ~keys_list;
% are there any fields, requested by input arguments:
%fields      = cell(1,sum(non_keys));
%fields(:)   = varargin(non_keys);
fields   = varargin(non_keys);

% does it requested to obtain thins which are not exist?
if ~all(ismember(fields,fields_recognized)) 
    unknown_fields= ~ismember(fields,fields_recognized);
    fprintf('ERROR: ->class requested to return unknown field:  %s\n',fields{unknown_fields});    
    error('RUNDATA:invalid_arguments','unknown fields requested in input parameters');    
end




function isit=is_key(key)
% the function which is applied to each element of cell array verifying if
% it is not a key
    isit = false;
    if key(1)=='-'
            isit = true;
    end

