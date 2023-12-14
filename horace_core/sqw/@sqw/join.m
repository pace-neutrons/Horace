function wout = join(w,varargin)
% Join an array of sqw objects into an single sqw object
% This is intended only as the reverse of split
%
%   >> wout = join(w,wi)
%   >> wout = join(w)
%
% Input:
% ------
%   w       array or cellarray of sqw objects or cellarray of names of sqw
%           files, each one made from a single spe data file
% Optional:
%   wi      initial pre-split sqw object (optional, recommended).
% outfile   if provided and input objects are filebacked, does resulting
%           combined object filebacked regardless of the fact that it may
%           fit memory.
%           Normally resulting object is filebacked or memory-based
%           depending on its size and hor_config mem_chunk_size and fb_scale_factor
%           settings.
% modifiers:
% '-allow_equal_headers'
%         -- if two objects of files from the list of input files contain
%            the same information
% '-recalc_runid'
%         -- if provided, recalculate existing run-id(s) stored in headers
%            in such way that pixels run-ids correspond to number of header
%            (IX_experiment) this run describes in the array of
%            Experiment.expdata headers (IX_experiments).
%
% Output:
% -------
%   wout    sqw object

% Original author: G.S.Tucker
% 2015-01-20

nfiles = numel(w);
% Catch case of single contributing spe dataset
if nfiles == 1
    wout = w;
    return
end
if nargin>1 && isa(varargin{1},'sqw')
    wi = varargin{1};
    argi = varargin(2:end);
else
    argi = varargin;
end
initflag = exist('wi','var') && wi.main_header.nfiles == nfiles;
opts = {'-allow_equal_headers','-recalc_runid'};
[ok,mess,allow_equal_headers,recalc_runid,argi] = parse_char_options(argi,opts);
if ~ok
    error('HORACE:join:invalid_argument',mess);
end
if ~isempty(argi) && istext(argi{1})
    outfile = argi{1};
else
    outfile = '';
end


% Default output
if initflag
    wout = sqw(wi);
    if isa(w,'sqw')
        w = num2cell(w);
    end
    % check if input data and the input sqw can indeed be combined together.
    check_img_consistency([{wout};w(:)],true);

    % build info for sqw combining
    [pix_list,npix_list] = cellfun(@extract_info, w,'UniformOutput',false);
    wout.pix = pixobj_combine_info(pix_list,npix_list);
    if recalc_runid
        wout.experiment_info.runid_map = 1:numel(w);
    end
else
    if allow_equal_headers
        argi = {'-allow_equal_headers'};
    else
        argi = {};
    end
    if ~recalc_runid
        argi = [argi(:),'-keep_runid'];
    end
    wout = collect_sqw_metadata(w,argi{:});
    if iscell(w)
        [fp,fn] = fileparts(w{1}.full_filename);
    else
        [fp,fn] = fileparts(w(1).full_filename);
    end
    wout.full_filename = fullfile(fp,['combined_',fn,'.sqw']);
end

page_op         = PageOp_join_sqw;
page_op.outfile = outfile;
%
if recalc_runid
    run_id = wout.runid_map.keys();
    run_id = [run_id{:}];
else
    run_id = [];
end

[page_op,wout]  = page_op.init(wout,run_id);
wout            = sqw.apply_op(wout,page_op);

end

function [pix,npix] = extract_info(in_sqw)
pix = in_sqw.pix;
npix = in_sqw.data.npix(:);
end
