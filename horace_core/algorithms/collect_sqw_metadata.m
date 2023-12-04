function [sqw_out,job_disp] = collect_sqw_metadata(inputs,varargin)
%COLLECT_SQW_METADATA collects metadata from varaious sqw objects provided 
% as input with the puprose of constructing single sqw object from these 
% input sqw objects.
% 
% The input sqw objects must have common image grid i.e. image ranges and
% number of image bins in every directions have to be the same for all
% conributing input objects
%
% Inputs:
% inputs  -- cellarray of files containing sqw objects or cellarray or array 
%            of filebacked or memorybased sqw objects to combine.
% Optional:
% '-allow_equal_headers'
%         -- if two objects of files from the list of input files contain
%            the same information
% '-keep_runid'
%         -- 
%
% Returns:
% sqw_out -- sqw object combined from input sqw objects and containing all
%            sqw object information except combined pixels.
%
% Throws HORACE:collect_sqw_metadata:invalid_argument if input objects
%           contain different grid or have equal data headers
options = {'-allow_equal_headers','-keep_runid'};
[ok,mess,allow_equal_headers,keep_runid,argi] = parse_char_options(varargin,options);
if ~ok
    error('HORACE:algorithms:invalid_argument',mess);
end

[data_range,job_disp]= parse_additional_input4_join_sqw_(argi);        
if iscell(inputs)
    istxt = cellfun(@istext,inputs);
    if all(istxt)
        [sqw_sum_struc,img_range,pix_data_range,job_disp]=get_pix_comb_info_(inputs, ...
            data_range,job_disp, ...
            allow_equal_headers,keep_runid);
        sqw_out = sqw(sqw_sum_struc);
    else
    end
else
end