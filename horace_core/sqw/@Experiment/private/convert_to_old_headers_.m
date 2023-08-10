function oldhdrs = convert_to_old_headers_(obj,nomangle,varargin)
%CONVERT_TO_OLD_HEADERS_ : convert Experiment into the structure suitable to be
% stored in old binary sqw files (up to version 3.xxx)
%
% this structure is also used in number of places of the old
% code where, e.g., structure sorting is implemented but this
% usage is deprecated and will be removed in a future.
%
% Optional Inputs:
% header_num -- if provided, convert only experiment data
%               corresponding to header number provided
% nomangle   -- if true, do not modify filename with
%               additional run_id information (normally assumed
%               "false" when writing new file or "true" when
%               upgrading file format
%
if ~isempty(varargin)
    header_num = varargin{1};
else
    header_num = [];
end

if ~isempty(header_num)
    if header_num > obj.n_runs || header_num<1
        error('HORACE:Experiment:invalid_argument', ...
            'Run N%d requested but experiment contains only %d runs', ...
            header_num,obj.n_runs)
    else
        inst = obj.instruments{header_num};
    end
    samp = obj.samples{header_num};
    oldhdrs = obj.expdata_(header_num).convert_to_binfile_header( ...
        '-inst_samp',inst,samp,nomangle);
else
    nruns = obj.n_runs;
    oldhdrs = cell(nruns,1);
    for i=1:nruns
        oldhdrs{i} = obj.expdata_(i).convert_to_binfile_header( ...
            '-inst_samp',                ...
            obj.instruments{i}, ...
            obj.samples{i},nomangle);
    end
end
