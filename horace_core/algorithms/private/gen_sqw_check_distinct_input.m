function [ok, mess, spe_only, head_only] = gen_sqw_check_distinct_input (spe_file, efix, emode,lattice,...
    instrument, sample,replicate, header_exper)
% Check that the input arguments to gen_sqw define distinct input with required equality of some fields.
% Optionally, determine in addition which input are not included in the header of an sqw file
%
%   >> status = gen_sqw_check_distinct_input (spe_file, efix, emode, sample,...
%                                              u, v, psi, omega, dpsi, gl, gs, instrument, sample)
%
%   >> [status, ind] = gen_sqw_check_distinct_input (spe_file, efix, emode, sample,...
%                                              u, v, psi, omega, dpsi, gl, gs, instrument, sample, header)
%
% Input:
% ------
%   spe_file        Cell array of spe file name(s)     [column vector length nfile]
%   efix            Fixed energy (meV)                 [column vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0   [column vector length nfile]
%   lattice         nfile array containing lattice parameters
%   instrument      Instrument descriptors (structure or object) [column vector length nfile]
%   sample          Sample descriptors (structure or object)    [column vector length nfile]
%   replicate       If ==true: allow non-distinct input; still perform the required equality checks
%
% Optional:
%   header          Header block from an sqw file. It is assumed that all spe data in
%                  the header are from distinct data sets.
%                  [structure for single spe file, or cell array of structures for more than one]
%
%
% Output:
% -------
%   ok              True if all are distinct; false otherwise.
%   mess            Message if not ok; ='' if ok.
%   spe_only        Logical array: true for entries into the input arguments that
%                  correspond to spe data that are NOT in the optional header.
%                   - If no header is provided, then spe_only=true for all spe entries
%   head_only       Logical array: true for entries into the header that do
%                  not correspond to spe data parameters
%                   - If no header is provided, then head_only=false(0,1)
%
%
% Notes:
% (1)  A set of valid parameters requires:
%     - All spe data must differ in at least one of the following
%             spe_file, efix, psi, omega, dpsi, gl, gs
%     - The contents of the following fields must be identical in all spe data:
%             emode, alatt, angdeg, u, v, sample
%     - Equality or otherwise of this parameter is irrelevant:
%             instrument
%
%     Note that the file name can be the same in two or more spe data input; this is
%     because we allow e.g. just one spe file to be used to generate a 'background'
%     with psi different for each spe data input.
%
% (2) The purpose of this routine is not to check the validity of the values of the
%     fields (e.g. that lattice parameters are greater than zero), but instead to
%     check the consistency of the equality or otherwise of the fields as required by later
%     algorithms in Horace.

% Make a stucture array of the fields that define uniqueness
% Convert angles to radians for comparison with header

emode_c = emode(1);
efix_is_array = false;
if emode_c == 2
    if size(efix,2)>1
        efix_is_array = true;
    end
end
% TODO: make lattice sortable
pstruct = lattice.to_bare_struct;
for i=1:numel(spe_file)
    pstruct(i).filename = spe_file{i};
    if ~efix_is_array
        pstruct(i).efix = efix(i);
    end    
end
names=fieldnames(pstruct)';     % row vector

% Sort structure array

[pstruct_sort,indp]=sortStruct(pstruct,names);
%pstruct_sort = pstruct;
%indp = 1:numel(spe_file);
%
tol = 1.0e-14;    % test number to define equality allowing for rounding errors in double precision
for i=2:numel(pstruct)
    if ~replicate && isequal(pstruct_sort(i-1),pstruct_sort(i))
        ok=false; spe_only=[]; head_only=[];
        mess='At least two spe data input have all the same filename, efix, psi, omega, dpsi, gl and gs'; return
    end
    ok = (emode(i)==emode(1));
    ok = ok & equal_to_relerr(lattice(i).u,lattice(1).u,tol,1);
    ok = ok & equal_to_relerr(lattice(i).v,lattice(1).v,tol,1);
    if ~ok
        spe_only=[]; head_only=[];
        mess=['Not all input spe data have the same values for energy mode (0,1,2)',...
            ', lattice parameters, projection axes and scattering plane u,v'];
        return
    end
    ok = isequal(sample(i),sample(1));
    if ~ok
        spe_only=[]; head_only=[];
        mess='Not all input spe data have the same fields or values of fields in the sample blocks';
        return
    end
end

% If a header was passed, check spe data arguments against contents of header
if ~exist('header_exper','var') || isempty(header_exper)
    ok=true;
    mess='';
    spe_only=true(numel(pstruct),1);
    head_only=false(0,1);
    
else
    % TODO:
    %Use header_combine to check the header and create a structure with the same fields as pstruct
    %HACK: fix to work properly. Move majority of the checks into
    %Experiment
    if ~isa(header_exper,'cell')
        header_exper = {header_exper};
    end
    %
    %header = cell(1,numel(header_exper));
    n_accum_runs = 0;
    for i=1:numel(header_exper)
        n_accum_runs  = n_accum_runs+header_exper{i}.n_runs;
    end
    
    exp_struc = Experiment().convert_to_old_headers(1);
    header = repmat(exp_struc,1,n_accum_runs);
    ic = 1;    
    for i=1:numel(header_exper)
        nr = header_exper{i}.n_runs;
        tmp_cell = header_exper{i}.convert_to_old_headers();
        tmp_cell = [tmp_cell{:}];
        header(ic:ic+nr-1) = tmp_cell(1:1+nr-1);        
        ic = ic+nr;
    end
    
    
    
    try
        [header_out,~,hstruct_sort,indh]=sqw_header.header_combine(header);
    catch ME
        if strcmp(ME.identifier,'HORACE:algorithms:invalid_argument')
            spe_only=[]; head_only=[];
            mess=['Error in sqw file header: ',ME.message];
            return
        else
            rethrow(ME);
        end
    end
    % % Check the fields are the same in pstruct and hstruct - to catch editing that has introduced inconsistencies
    names_hstruct_sort=fieldnames(hstruct_sort)';
    %if numel(names)~=numel(names_hstruct_sort) || ~all(strcmp(names,names_hstruct_sort))
    %    error('Fieldnames not identical in pstruct and hstruct: error in code; see T.G.Perring')
    %end
    %HACK:
    in_names = ismember(names_hstruct_sort,names);
    extra_names  = names_hstruct_sort(~in_names);
    hstruct_sort = rmfield(hstruct_sort,extra_names);    
    
    % % Find the entries in pstruct_sort that also appear in hstruct_sort
     i=1; j=1; n1=numel(pstruct_sort); n2=numel(hstruct_sort);
     pcommon=false(n1,1); hcommon=false(n2,1);
     tol = 2.0e-7;    % test number to define equality allowing for rounding errors (recall header fields were saved only as float32)
     while (i<=n1 && j<=n2)
         if equal_to_tol(pstruct_sort(i),hstruct_sort(j),-tol,'min_denominator',1)
             pcommon(i)=true;
             hcommon(j)=true;
             i=i+1;
             j=j+1;
         else
             [tmp,tmpind]=sortStruct([pstruct_sort(i),hstruct_sort(j)],names);
             if tmpind(1)==1
                 i=i+1;
             else
                 j=j+1;
             end
         end
     end
     ip0=indp(pcommon); ih0=indh(hcommon);   % indicies of the common entries in the original structure arrays
     % Check that the fields that are required to be equal are indeed
     for i=1:numel(ip0)
         ok = (emode(ip0(i))==header_out{ih0(i)}.emode);
         ok = ok & equal_to_relerr(dsd(alatt(ip0(i),:)),header_out{ih0(i)}.alatt,tol,1);
         ok = ok & equal_to_relerr(dsd(angdeg(ip0(i),:)),header_out{ih0(i)}.angdeg,tol,1);
         ok = ok & equal_to_relerr(dsd(u(ip0(i),:)),header_out{ih0(i)}.cu,tol,1);
         ok = ok & equal_to_relerr(dsd(v(ip0(i),:)),header_out{ih0(i)}.cv,tol,1);
         if ~ok
             spe_only=[]; head_only=[];
             mess='spe data and header of sqw file are inconsistent';
             return
         end
         ok = isequal(sample(ip0(i)),header_out{ih0(i)}.sample);
         if ~ok
             spe_only=[]; head_only=[];
             mess='spe data and header of sqw file have inconsistent sample information';
             return
         end
         ok = isequal(instrument(ip0(i)),header_out{ih0(i)}.instrument);   % we require the instrument is also equal
         if ~ok
             spe_only=[]; head_only=[];
             mess='spe data and header of sqw file have inconsistent instrument information';
             return
         end
     end
     ok=true;
     mess='';
     spe_only=true(numel(pstruct),1);
     head_only=true(numel(header_out),1);
     spe_only(ip0)=false;
     head_only(ih0)=false;
    
end

%--------------------------------------------------------------------------]
function xout=dsd(xin)
% Take double precision elements, convert to single precision, and back to double
%
%   >> xout=dsd(xin)
%
% Input:
% ------
%   xin     An array, cell array, structure array or object array
%
% Output:
% -------
%   xout    Same type as input, wit all double extries converted to single
%          and back again. The goal is tue simulate the effect of writing
%          as float32 and reading back as float32 into a double.

xout=xin;
if isa(xin,'double')
    xout=double(single(xin));
    
elseif iscell(xin)
    for i=1:numel(xin)
        xout{i}=dsd(xin{i});
    end
    
elseif isstruct(xin) || isobject(xin)
    names=fieldnames(xin);
    for i=1:numel(xin)
        for j=1:numel(names)
            xout(i).(names{j})=dsd(xin(i).(names{j}));
        end
    end
    
end


