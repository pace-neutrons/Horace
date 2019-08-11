function obj = put_instr_sampl_info_(obj,instrument_or_sample,varargin)
% Store or change sample and instrument information in the sqw file v3
%
% Usage:
%>>obj = obj.put_instr_sampl_info_(obj,'instrument',instrument_info)
%>>obj = obj.put_instr_sampl_info_(obj,'sample',sample_info)
%
% setting only sample stores the instrument information too.
% file footer is always overwritten.
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%

%
[ok,message,has_instrument,has_sample,argi] = parse_char_options(varargin,{'instrument','sample'});
if ~ok
    error('SQF_FILE_IO:invalid_argument',message)
end

[inst_obj,argi]=extract_is_from_input(obj,has_instrument,'instrument',instrument_or_sample,varargin,argi);
[sample_obj,argi]=extract_is_from_input(obj,has_sample,'sample',instrument_or_sample,varargin,argi);

sh = is_holder(inst_obj,sample_obj); % pack instrument and sample into single class
if ~sh.is_empty()
    argi{end+1} = sh;
end

obj= put_sample_instr_records_(obj,argi{:});

obj.position_info_pos_= obj.instr_sample_end_pos_;
obj = obj.put_footer();


function [the_obj,argi]=extract_is_from_input(obj,has_object,obj_name,default_name,all_arg,argi)
% extract instrument or sample data from input stream.
% Inputs:
% has_object  -- true if appropriate keyword was identified in the input
% obj_name    -- the name of the keyword identified
% default_name -- what object (instrument or sample) to assume if some
%                 unspecified data are found
% all_arg      -- cellarray of all arguments
% argi         -- cellarray of arguments excluding 'instrument' or
%                  'sample' keywords
% Returns
% the_obj      -- information, for the keyword provided, or empty if not
%                 found
% argi         -- cellarray of the inputs excluding the_obj
%

the_obj = [];
if has_object
    the_pos = ismember(all_arg,obj_name);
    ii = find(the_pos)+1;
    if ii > numel(all_arg)
        error('SQF_FILE_IO:invalid_argument',...
            '"%s" keyword has to be followed by an object, containing %s information',obj_name,obj_name)
    end
    the_obj  = all_arg{ii};
    inargi = cellfun(@(x)(x==the_obj),argi,'UniformOutput',true);
    argi = argi(~inargi);
else
    if strcmp(obj_name,default_name)
        if numel(argi) > 0
            if isa(argi{1},'sqw')
                return;
            else
                the_obj =  argi{1};
            end
        end
        if numel(argi) > 1
            argi = argi(2:end);
        else
            argi ={};
        end
    end
end
