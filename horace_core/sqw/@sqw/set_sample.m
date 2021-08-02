function varargout = set_sample (varargin)
% Change the sample in an sqw object or array of objects
%
%   >> wout = set_sample (w, sample)
%
%
% Input:
% -----
%   w           Input sqw object or array of objects
%
%   sample      Sample object (IX_sample object) or structure
%              Note: only a single sample object can be provided. That is,
%              there is a single sample for the entire sqw data set.
%               If the sample is any empty object, then the sample is set
%              to the default empty structure.
%
% Output:
% -------
%   wout        Output sqw object with changed sample


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


% This routine is also used to set the sample in sqw files, when it overwrites the input file.

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
narg=numel(args);
if narg==0
    % Nothing to do
    if w.source_is_file
        argout={};
    else
        argout{1}=w.data;
    end
elseif narg==1
    if isscalar(args{1}) && (isstruct(args{1}) || isa(args{1},'IX_sample'))
        sample=args{1};     % single structure or IX_sample
    elseif isempty(args{1})
        sample=struct();    % empty item indicates no sample; set to default 1x1 empty structure
    else
        error('Sample must be a scalar structure or IX_sample object (or an empty argument to indicate ''no sample'')')
    end

    % Check that the data has the correct type
    if ~all(w.sqw_type(:))
        error('Sample can only be set or changed in sqw-type data')
    end   
    % Change the sample
    if w.source_is_file
        set_sample_horace(w.loaders_list,sample);
        argout={};
    else
        wout=w.data;
        for i=1:numel(wout)
            nfiles=wout(i).main_header.nfiles;
            tmp=wout(i).header_x;   % to keep referencing to sub-fields to a minimum
            for ifiles=1:nfiles
                % the default sample already present will have been set up
                % with alatt and angdeg values from old-style headers. 
                % The new sample being entered may not have these. 
                % Here we assume that the pregenerated sample values are
                % not valid.
                oldsample = tmp.samples(ifiles);
                sample.alatt = oldsample.alatt;
                sample.angdeg = oldsample.angdeg;
                tmp.samples(ifiles)=sample;
            end
            wout(i).header_x=tmp;
        end
        argout{1}=wout;
    end
else
    error('Check the number of input arguments')
end


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end

