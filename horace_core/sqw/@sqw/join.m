function wout = join(w,wi,varargin)
% Join an array of sqw objects into an single sqw object
% This is intended only as the reverse of split
%
%   >> wout = join(w,wi)
%   >> wout = join(w)
%
% Input:
% ------
%   w       array of sqw objects, each one made from a single spe data file
% Optional:
%   wi      initial pre-split sqw object (optional, recommended).
%
% modifiers:
% '-allow_equal_headers'
%         -- if two objects of files from the list of input files contain
%            the same information
% '-keep_runid'
%         -- if provided, keep existing run_id(s) stored in headers

%
% Output:
% -------
%   wout    sqw object

% Original author: G.S.Tucker
% 2015-01-20

nfiles = length(w);
% Catch case of single contributing spe dataset
if nfiles == 1
    wout = w;
    return
end

initflag = exist('wi', 'var') && ~isempty(wi) && isa(wi, 'sqw') ...
    && wi.main_header.nfiles == nfiles;

% Default output
if initflag
    wout = sqw(wi);
    if iscell(w)
        [pix_list,npix_list] = cellfun(@extract_info,in_sqw,'UniformOutput',false);
    else
        [pix_list,npix_list] = arrayfun(@extract_info,in_sqw,'UniformOutput',false);
    end
    wout.pix = pixobj_combine_info(pix_list,npix_list);
else
    wout = collect_sqw_metadata(w);
end

page_op        = PageOp_join_sqw;
[page_op,wout] = page_op.init(wout);
wout           = sqw.apply_op(wout,page_op);

end

function [pix,npix] = extract_info(in_sqw)
pix = in_sqw.pix;
npix = in_sqw.data.npix(:);
end
