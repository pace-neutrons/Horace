function [sqw_out,job_disp] = collect_sqw_metadata(inputs,varargin)
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
%            of filebacked or memorybased sqw objects to combine.
% Optional:
% '-allow_equal_headers'
%         -- if two objects of files from the list of input files contain
%            the same information
% '-keep_runid'
%         -- if provided, keep existing run_id(s) according to numbers, 
%            stored in headers. If not, recaluclate runID as sum of file inputs.
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

[pix_data_range,job_disp]= parse_additional_input4_join_sqw_(argi);
if iscell(inputs)
    istxt = cellfun(@istext,inputs);
    if all(istxt)
        [sqw_sum_struc,pix_data_range,job_disp]=get_pix_comb_info_(inputs, ...
            pix_data_range,job_disp, ...
            allow_equal_headers,keep_runid);

    elseif all(cellfun(@(x)isa(x,'sqw'),inputs))
        sqw_sum_struc=get_pix_comb_info_from_sqw(inputs, ...
            pix_data_range, ...
            allow_equal_headers,true);

    else
        is_sqw = cellfun(@(x)isa(x,'sqw'),inputs);
        non_sqw = inputs(~is_sqw);
        error('HORACE:algorithms:invalid_argument', ...
            ['This routine accepts only list of sqw files or sqw objects.\n' ...
            ' First non-sqw object class is %s'],class(non_sqw{1}));
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
    sqw_sum_struc=get_pix_comb_info_from_sqw(inputs, ...
        pix_data_range, ...
        allow_equal_headers,true);

end
sqw_out = sqw(sqw_sum_struc);

function  sqw_sum_struc=get_pix_comb_info_from_sqw(inputs, ...
    pix_data_range, ...
    allow_equal_headers,keep_runid)

[img_hdrs,experiments_from_sqw,pix] = cellfun(@extract_sqw_parts,inputs,'UniformOutput',false);

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
pix = pixobj_combine_info(pix,numel(dnd_data.npix));
pix.run_label = run_label;
pix.data_range = pix_data_range;

det = inputs{1}.detpar; % To modify according to new interface
sqw_sum_struc= struct('main_header',mhc,'experiment_info',exper_combined,'detpar',det);
sqw_sum_struc.data = dnd_data;
sqw_sum_struc.pix = pix;

function [img_meta,experiments,pix] = extract_sqw_parts(the_sqw)
img_meta = the_sqw.get_dnd_metadata();
experiments = the_sqw.experiment_info;
pix = the_sqw.pix;
