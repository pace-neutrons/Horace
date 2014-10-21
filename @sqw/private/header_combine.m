function [header_out,run_label,ok,mess,hstruct_sort,ind] = header_combine(header, single)
% Combine header blocks to form a single block
%
%   >> [header_out,nfiles,ok,mess] = header_combine(header)
%   >> [header_out,nfiles,ok,mess] = header_combine(header, single)
%
% Input:
% ------
%   header      Cell array of header blocks from a number of sqw files.
%               Each header block is a structure (single spe file) or a cell
%              array of single structures.
%               Note:
%               - The case of a single header block with a single spe file is
%                correctly caught as such.
%               - There is an ambiguity when trying to catch the case of a single
%                header block with multiple spe files: this will be a cell array
%                of single structures, which will be interpreted as multiple
%                header blocks, each with a single spe file. To ensure that the
%                argument 'header' is interpreted as a single header block,
%                either put in a cell array with one element, or set the
%                optional argument 'single' below.
%
%   single      [optional] If present, require 'header' to come fron a single header
%              block (if true) or from multiple set of header blocks (if false)
%               If absent, intepret the ambiguity as multiple header blocks
%
% Output:
% -------
%   header_out  Header block for a single sqw file that combines all the input
%              sqw files. (Note that if a single spe file, this is a structure
%              otherwise it is a cell array. This is the standard format for
%              an sqw file.) [column vector]
%
%   run_label   Structure that defines how run indicies in the sqw data must be
%              renumbered. Arrays ix and ixarr are filled for all cases; For the
%              simple but frequent cases of nochange or simple offset
%              that information is stored too.
%           run_label.ix        Cell array with length equal to the number of data sources,
%                              each entry being a column vector of the new labels for the
%                              corresponding run in the output sqw data. That is, ix{i}(j)
%                              is the new run number for the jth run of the ith sqw file.
%           run_label.ixarr     Alternative representation of the same information: an
%                              array with size [<max_number_runs_in_a_header_block>,
%                              <number_of_header_blocks>] so that each column contains the
%                              new labels for the corresponding run in the output sqw data.
%                              That is, ix(i,j) is the index of the entry in header_out
%                              corresponding to the ith run of the jth input sqw file.
%           run_label.nochange  true if the run indicies in all header blocks are
%                              to be left unchanged [this happens when combining
%                              sqw data from cuts taken from the same master sqw file]
%           run_label.offset    If not empty, then contains array length equal to
%                              the number of input header blocks with offsets to add
%                              to the corresponding runs [this happens typically when
%                              using gen_sqw or accumulate_sqw, as every sqw file
%                              corresponds to a different spe file]
%
%   ok          True if no problems combining, false otherwise
%
%   mess        Error message if not ok; equal to '' if ok
%
%   hstruct_sort Array of structures with the fields that define uniqueness of a
%              header entry
%
%   ind         Index of hstruct_sort of equivalent entry in header_out. That is,
%              hstruct_sort corresponds to header_out(ind).
%
%
% Notes:
% ------
% (1) Each header block is assumed to come from a valid sqw object, and by definition this
%    means that the individual headers in a header block should correspond to distinct runs.
%    By disinct runs we mean that:
%     - the individual headers must differ in at least one of the following quantities
%           fullfile(filepath,filename), efix, psi, omega, dpsi, gl, gs
%
%     - and because the the runs are distinct, there is no requirement on equality or
%      otherwise of:
%           en, ulabel, instrument
%
%    However, to be from a valid sqw object:
%     - the contents of the following fields must be identical in all individual headers:
%           emode, alatt, angdeg, cu, cv, uoffset, u_to_rlu, ulen, sample
%
% (2) For sqw data to be combined, we require that emode, alatt... sample are the
%    same for all individual headers. Beyond this, the individual headers from different
%    header blocks must either correspond to different runs, that is, be distinct in the
%    sense defined above, or to correspond to identical runs, that is, all fields
%    must be the same (including en, ulabel, instrument).
%
%  *** Actually, should insist that the structure of instrument is the same in all headers
%      although the values of fields in nested structures and arrays can be different
%
%
% NB/ The purpose of this routine is not to check the validity of the values of the
% fields (e.g. that lattice parameters are greater than zero), but instead to
% check the consistency of the equality or otherwise of the fields as required by other
% algorithms in Horace.


tol = 2.0e-7;   % test number to define equality allowing for rounding errors

hstruct=struct('filename','','efix',[],'psi',[],'omega',[],'dpsi',[],'gl',[],'gs',[]);

force_single_header_block=(nargin==2 && single);
force_multiple_header_block=(nargin==2 && ~single);


% Catch cases of a single header block with a single spe file - no processing required.
% -------------------------------------------------------------------------------------
if isstruct(header) || (iscell(header) && numel(header)==1 && isstruct(header{1}))
    if force_multiple_header_block
        [header_out,run_label,ok,hstruct_sort,ind] = output_on_error;
        mess=['Input argument ''header'' inconsistent with the declaration it comes '...
            'from more than one header block'];
        return
    end
    if isstruct(header)
        header_out=header;
    else
        header_out=header{1};
    end
    run_label=struct('ix',{{1}},'ixarr',1,'nochange',true,'offset',[]);
    ok=true;
    mess='';
    hstruct_sort=hstruct;
    names=fieldnames(hstruct);
    for j=1:numel(names)
        if j==1
            hstruct_sort.filename=fullfile(header_out.filepath,header_out.filename);
        else
            hstruct_sort.(names{j})=header_out.(names{j});
        end
    end
    ind=1;
    return
end


% At least two headers (but maybe only one header block).
% -------------------------------------------------------
% Get number of elements in each header block
if force_single_header_block
    for i=1:numel(header)
        if ~isstruct(header{i})
            [header_out,run_label,ok,hstruct_sort,ind] = output_on_error;
            mess=['Input argument ''header'' inconsistent with the declaration it contains '...
                'headers from just one header block'];
            return
        end
    end
    header={header};    % make a scalar cell array containing a cell array of structures
end

nsqw=numel(header);
nspe=zeros(nsqw,1);
for i=1:nsqw
    if ~iscell(header{i})
        nspe(i)=1;
    else
        nspe(i)=numel(header{i});
    end
end

% Special case: all header blocks are identical. This happens if combining cuts made from
% just one sqw file. Can vastly optimise the code in this case as it is cheap to check
% equality of headers, but much more expensive to do all the equal_to_tol and equal_to_relerr
% checks repeatedly on loads of identical header blocks, each of which might contain hundreds
% of headers. If all header blocks are equal, then all we need to do is check one header block
if nsqw>1 && all(nspe==nspe(1))
    all_same_header_block=true;
    for i=2:nsqw
        if ~isequal(header{i-1},header{i})
            all_same_header_block=false;
            break
        end
    end
    if all_same_header_block
        nsqw=1;
        nspe=nspe(1);
    end
end

% Construct output header block
nfiles_tot=sum(nspe);
header_out=cell(nfiles_tot,1);
ibeg=1;
for i=1:nsqw
    if nspe(i)==1
        header_out(ibeg)=header(i);   % header for a single file is just a structure
        ibeg=ibeg+1;
    else
        header_out(ibeg:ibeg+nspe(i)-1)=header{i};    % header for more than one file is a cell array
        ibeg=ibeg+nspe(i);
    end
end


% Check the headers are all unique across the relevant fields, and have equality in other required fields
% -------------------------------------------------------------------------------------------------------
% Even if there is just one header block the following checks are performed to ensure
% that the individual headers are unique (we have already caught the case of a single
% header in a single header block)

% Make a stucture array of the fields that define uniqueness
hstruct=repmat(hstruct, size(header_out));
names=fieldnames(hstruct);
for i=1:nfiles_tot
    for j=1:numel(names)
        if j==1
            hstruct(i).filename=fullfile(header_out{i}.filepath,header_out{i}.filename);
        else
            hstruct(i).(names{j})=header_out{i}.(names{j});
        end
    end
end

% Sort structure array, determine if headers correspond to data that can be combined
% and find unique headers
[hstruct_sort,ind]=nestedSortStruct(hstruct,names');
isqw=replicate_iarray(1:nsqw,nspe);
isqw=isqw(ind); % list of sqw object numbers corresponding to the sorted header list

h_unique=false(size(hstruct));
h_unique(1)=true;
indh=zeros(size(hstruct));  % array to hold index in list of unique elements of hstruct_sort
indh(1)=1;  % first element of hstruct_sort is by definition unique
j=1;        % counter of unique elements of hstruct_sort
for i=2:nfiles_tot
    % Check equality of fields that must be the same for all headers
    ok = (header_out{i}.emode==header_out{1}.emode);
    ok = ok & equal_to_relerr(header_out{i}.alatt, header_out{1}.alatt, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.angdeg, header_out{1}.angdeg, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.cu, header_out{1}.cu, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.cv, header_out{1}.cv, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.uoffset, header_out{1}.uoffset, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.u_to_rlu(:), header_out{1}.u_to_rlu(:), tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.ulen, header_out{1}.ulen, tol, 1);
    if ~ok
        header_out=cell(0,1);
        run_label=struct('ix',{{}},'ixarr',[],'nochange',false,'offset',[]);
        ok=false;
        mess=['Not all input files have the same values for energy mode (0,1,2), lattice parameters,',...'
            'projection axes and projection axes offsets in the header blocks'];
        hstruct_sort=struct([]); ind=[];
        return
    end
    ok = isequal(header_out{i}.sample, header_out{1}.sample);
    if ~ok
        [header_out,run_label,ok,hstruct_sort,ind] = output_on_error;
        mess='Not all input files have the same fields or values of the fields in the sample in the header blocks';
        return
    end
    
    % Check if headers correspond to distinct runs or not
    if equal_to_tol(hstruct_sort(i-1),hstruct_sort(i),-tol,'min_denominator',1)
        % If runs are identical, check that they come from different sqw objects
        if isqw(i-1)==isqw(i)
            [header_out,run_label,ok,hstruct_sort,ind] = output_on_error;
            mess='At least two headers in the same sqw data have the all the same filename, efix, psi, omega, dpsi, gl and gs';
            return
        end
        % Check that en, ulabel, instrument are equal
        ok = (numel(header_out{i-1}.en)==numel(header_out{i}.en));
        ok = ok & equal_to_relerr(header_out{i-1}.en, header_out{i}.en, tol, 1);
        ok = ok & isequal(header_out{i-1}.ulabel, header_out{i}.ulabel);
        ok = ok & isequal(header_out{i-1}.instrument, header_out{i}.instrument);
        if ~ok
            [header_out,run_label,ok,hstruct_sort,ind] = output_on_error;
            mess='One or more instances of same runs with different energy bins, instrument or axes labels';
            return
        end
    else
        j=j+1;  % increment unique header counter
        h_unique(i)=true;
    end
    indh(i)=j;
end


% Fill output arguments
% ---------------------
% All the header blocks have been checked to be internally OK and also valid for combining
ok=true;
mess='';
run_label=struct('ix',{{}},'ixarr',[],'nochange',false,'offset',[]);

if nsqw==1
    % Only one header block (or one distinct header block) - now confirmed to be OK
    ix=repmat({(1:nspe)'},1,numel(header));     % allow for case where nsqw==1 because all header were the same
    ixarr=repmat((1:nspe)',1,numel(header));
    run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',true,'offset',[]);
    
elseif all(h_unique)
    % All sqw data have different runs
    ix=mat2cell((1:sum(nspe))',nspe);
    ixarr=zeros(max(nspe),numel(nspe));
    for i=1:numel(nspe)
        ixarr(1:nspe(i),i)=ix{i};
    end
    offset=cumsum([0;nspe(1:end-1)]);
    run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',false,'offset',offset);
    
else
    % General case
    indx=find(h_unique);    % indicies of unique headers in hstruct_sort
    header_out=header_out(ind(indx));   % corresponding full headers
    indh(ind)=indh;         % indicies of unique elements in hstruct_sort, in the order of spe files in the headers
    ix=mat2cell(indh,nspe);
    ixarr=zeros(max(nspe),numel(nspe));
    for i=1:numel(nspe)
        ixarr(1:nspe(i),i)=ix{i};
    end
    run_label=struct('ix',{ix},'ixarr',ixarr,'nochange',false,'offset',[]);
    hstruct_sort=hstruct_sort(indx);
    ind=(1:numel(indx))';   % we have sorted the headers to match hstruct_sort
    
end


%==================================================================================================
function [header_out,run_label,ok,hstruct_sort,ind] = output_on_error
% Return standard values if error
header_out=cell(0,1);
run_label=struct('ix',{{}},'ixarr',[],'nochange',false,'offset',[]);
ok=false;
hstruct_sort=struct([]);
ind=[];
