function wout = join(w,varargin)
% Join an array or cellarray of sqw objects or sqw files into an single sqw
% object.
%
% The objects must have common image shape, like objects produced by split
% or files stored by gen_sqw(___,'-tmp_only') option.
%
%   >> wout = join(w,wi,varargin)
%   >> wout = join(w,varargin)
%
% Input:
% ------
%   w       array or cellarray of sqw objects or cellarray of names of sqw
%           files, each one have the same image shape, i.e. size(sqw.data.s)
%           have to be the same for all contributing images.
% Optional:
%   wi      initial pre-split sqw object (optional, recommended).
% outfile   if provided and input objects are filebacked, makes resulting
%           combined object filebacked regardless of the fact that it may
%           fit memory.
%           Normally resulting object is filebacked or memory-based
%           depending on its size and hor_config mem_chunk_size and 
%           fb_scale_factor settings.
% modifiers:
% '-allow_equal_headers'
%         -- if two objects of files from the list of input files contain
%            the same information join fail. If this option is provided, 
%            such objects allowed.
% '-recalc_runid'
%         -- if provided, recalculate existing run-id(s) stored in pixels
%            and headers (Experiment.exp
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
    if istext(wout)
        wout = sqw(wout);
    end
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
    [~,ldrs] = check_img_consistency([{wout};w(:)]);
    if ~isempty(ldrs{1})
        ldrs{1} = ldrs{1}.delete(); % close loader for reference file
    end
    ldrs = ldrs(2:end); % remove loader for reference object if any

    membased = cellfun(@isempty,ldrs);
    if all(membased )
        % build info for sqw combining
        [pix_list,npix_list] = cellfun(@extract_info, w,'UniformOutput',false);
        wout.pix = pixobj_combine_info(pix_list,npix_list);
        if recalc_runid
            wout.experiment_info.runid_map = 1:numel(w);
        end
    else
        if any(membased)
            close_lrds(ldrs);
            error('HORACE:sqw:not_implemented', ...
                'join combines either input files or input objects. Possibility to mix them is not implemented');
        end
        if recalc_runid
            run_label = 1:numel(w);
        else
            run_label = 'nochange';
        end
        [npixtot,pos_npixstart,pos_pixstart] = cellfun(@extract_info_from_ldrs, ldrs);
        pix = pixfile_combine_info(w,numel(wout.data.npix),npixtot, ...
            pos_npixstart,pos_pixstart,run_label);
        pix.data_range = wout.pix.data_range;
        wout.pix = pix;
        close_lrds(ldrs);
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
end

hpc = hpc_config;
hc = hor_config;
use_mex = hc.use_mex && strncmp(hpc.combine_sqw_using,'mex',3);

page_op         = PageOp_join_sqw;
page_op.outfile = outfile;
%
if recalc_runid
    run_id = wout.runid_map.keys();
    run_id = [run_id{:}];
else
    run_id = [];
end

[page_op,wout]  = page_op.init(wout,run_id,use_mex);
wout            = sqw.apply_op(wout,page_op);
if isempty(wout.full_filename)
    % this may happen if combined from memory without reference object
    wout.full_filename = page_op.outfile;
end

end
%
function [pix,npix] = extract_info(in_sqw)
pix = in_sqw.pix;
npix = in_sqw.data.npix(:);
end
%
function [npixtot,pos_npixstart,pos_pixstart]=extract_info_from_ldrs(ldr)
pos_npixstart=ldr.npix_position;  % start of npix field
pos_pixstart =ldr.pix_position;   % start of pix field
npixtot      =ldr.npixels;
end

function ldrs = close_lrds(ldrs)
% close loader handles in case of error
for i=1:numel(ldrs)
    if ~isempty(ldrs{i})
        ldrs{i} = ldrs{i}.delete();
        ldrs{i} = [];
    end
end
end