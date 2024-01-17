function [sqw_out,pix_data_range,job_disp] = collect_sqw_metadata(inputs,varargin)
%COLLECT_SQW_METADATA collects metadata from various sqw objects provided
% as input with the purpose of constructing single sqw object from these
% input sqw objects.
%
% The input sqw objects must have common image grid i.e. image ranges and
% number of image bins in every directions have to be the same for all
% contributing input objects
%
% Inputs:
% inputs  -- cellarray of files containing sqw objects or cellarray or array
%            of filebacked or memory-based sqw objects to combine.
% Optional:
% '-allow_equal_headers'
%         -- if two objects or files from the list of input files contain
%            the same information, allow this. Would throw invalid_arguments
%            otherwise.
% '-keep_runid'
%         -- if provided, keep existing run_id(s) according to numbers,
%            stored in headers. If not, recalculate runID according to number
%            of input files.
%
% Returns:
% sqw_out -- pixel-less sqw object combined from input sqw objects and
%            containing all sqw object information except combined pixels.
%            Pixels are represented not by a PixelData class but by a
%            class, which provides information about how to combine pixels.
%
% Throws HORACE:collect_sqw_metadata:invalid_argument if input objects
%           contain different grid or have equal data headers
options = {'-allow_equal_headers','-keep_runid'};
[ok,mess,allow_equal_headers,keep_runid,argi] = parse_char_options(varargin,options);
if ~ok
    error('HORACE:algorithms:invalid_argument',mess);
end

[pix_data_range,job_disp]= parse_additional_input4_join_sqw_(argi{:});
if iscell(inputs)
    if all(cellfun(@istext,inputs))
        [sqw_sum_struc,pix_data_range,job_disp]=get_pix_comb_info_(inputs, ...
            pix_data_range,job_disp, ...
            allow_equal_headers,keep_runid);

    elseif all(cellfun(@(x)isa(x,'sqw'),inputs))
        [sqw_sum_struc,pix_data_range]=get_pix_comb_info_from_sqw(inputs, ...
            pix_data_range, ...
            allow_equal_headers,keep_runid);

    else
        is_known = cellfun(@(x)(isa(x,'sqw')||@(x)istext(x)),inputs);
        non_sqw = inputs(~is_known);
        error('HORACE:algorithms:invalid_argument', ...
            ['This routine accepts only list of sqw files or sqw objects.\n' ...
            ' First unknown object''s class is: %s'],class(non_sqw{1}));
    end
else
    is_sqw = arrayfun(@(x)isa(x,'sqw'),inputs);
    if ~all(is_sqw)
        non_sqw = inputs(~is_sqw);
        error('HORACE:algorithms:invalid_argument', ...
            ['This routine accepts only list of sqw files or array/list of sqw objects.\n' ...
            ' First non-sqw object class is: %s'],class(non_sqw(1)));

    end
    inputs = num2cell(inputs);
    [sqw_sum_struc,pix_data_range] =get_pix_comb_info_from_sqw(inputs, ...
        pix_data_range,allow_equal_headers,keep_runid);

end
sqw_out = sqw(sqw_sum_struc);
end

function  [sqw_sum_struc,pix_data_range] = get_pix_comb_info_from_sqw(inputs, ...
    pix_data_range, allow_equal_headers,keep_runid)
% Construct information about pixel distribution from cellarray of sqw objects in
% memory

[img_hdrs,experiments_from_sqw,pix,npix] = cellfun(@extract_sqw_parts,inputs,'UniformOutput',false);

ll = config_store.instance().get_value('hor_config','log_level');

[dnd_data,exper_combined,mhc] = combine_exper_and_img_( ...
    experiments_from_sqw,img_hdrs,inputs,allow_equal_headers,keep_runid, ...
    [],ll);



% Prepare writing to output file
% ---------------------------
if keep_runid
    run_label = 'nochange';
else
    keys = exper_combined.runid_map.keys;
    run_label=[keys{:}];
end
% % instead of the real pixels to place in target sqw file, place in pix field the
% % information about the way to get the contributing pixels
pix = pixobj_combine_info(pix,npix);
pix.run_label = run_label;
if ~any(pix_data_range(:) == PixelDataBase.EMPTY_RANGE(:))
    pix.data_range = pix_data_range;
end
pix_data_range = pix.data_range;

det = inputs{1}.detpar_struct; % To modify according to new interface $DET
sqw_sum_struc= struct('main_header',mhc,'experiment_info',exper_combined,'detpar',det);
sqw_sum_struc.data = dnd_data;
sqw_sum_struc.pix = pix;
end

function [img_meta,experiments,pix,npix] = extract_sqw_parts(the_sqw)
img_meta = the_sqw.get_dnd_metadata();
experiments = the_sqw.experiment_info;
pix = the_sqw.pix;
npix = the_sqw.data.npix(:);
end