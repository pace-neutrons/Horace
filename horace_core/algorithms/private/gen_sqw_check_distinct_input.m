function [spe_only, head_only] = gen_sqw_check_distinct_input (spe_file, efix, emode,lattice,...
    instrument, sample,replicate, exper_info)
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
%   exper_info     The Experiment object containg the experiment info
%                  stored in an sqw file.
%
% Output:
% -------
%   spe_only        Logical array: true for entries into the input arguments that
%                   correspond to spe data that are NOT in the optional header.
%                   - If no header is provided, then spe_only=true for all spe entries
%   head_only       Logical array: true for entries into the header that do
%                   not correspond to spe data parameters
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

% get comparison info for spe files
emode_c = emode(1);
efix_is_array = false;
if emode_c == 2
    if size(efix,2)>1
        efix_is_array = true;
    end
end
% get fields to compare against
comp_fields   = IX_experiment.unique_prop;
n_comp_fields = numel(comp_fields);
comp_val      = cell(numel(comp_fields),numel(spe_file));
pstruct       = cell2struct(comp_val,comp_fields);
for i_spe =1:numel(spe_file)
    for j=1:n_comp_fields
        fld = comp_fields{j};
        if isprop(lattice(i_spe),fld)
            pstruct(i_spe).(fld) = single(lattice(i_spe).(fld));
        end
    end
    [~,fn,fe] = fileparts(spe_file{i_spe});
    pstruct(i_spe).filename =[fn,fe];
    if ~efix_is_array
        pstruct(i_spe).efix = efix(i_spe);
    end
end
comp_fields=comp_fields(:)';  % ensure row vector

% Sort structure array
[pstruct_sort,indp]=sortStruct(pstruct,comp_fields);
%pstruct_sort = pstruct;
%indp = 1:numel(spe_file);
%
for i_spe=2:numel(pstruct)
    if ~replicate && isequal(pstruct_sort(i_spe-1),pstruct_sort(i_spe))
        error('HORACE:gen_sqw:invalid_argument',...
            ['At least two spe data input have all the same filename, efix, psi, omega, dpsi, gl and gs\n' ...
            'difference between headers %d and %d which are: %s\n and %s\n'],...
            i_spe-1,i_spe,disp2str(pstruct_sort(i_spe-1)),pstruct_sort(i_spe));
    end

    if emode(i_spe)~=emode(1)
        error('HORACE:gen_sqw:invalid_argument',...
            ['Not all input spe data have the same values for energy mode (0,1,2)' ...
            'Emode for run 1: %d, Emode for run %d: %d'],emode(1),i_spe,emode(i_spe));
    end
    if ~equal_to_tol(sample(i_spe),sample(1))
        error('HORACE:gen_sqw:invalid_argument',...
            ['Not all input spe data have the same fields or values of fields in the sample blocks' ...
            'Different sample N1 and sample N%d'],i_spe);

    end
end

% If a header was passed, check spe data arguments against contents of header
if ~exist('exper_info','var') || isempty(exper_info)
    spe_only=true(numel(pstruct),1);
    head_only=false(0,1);
    return
end
%Use header_combine to check the header and create a structure with the same fields as pstruct
if ~isa(exper_info,'cell')
    exper_info = {exper_info};
end
%
% Convert experiment-s info into the structure, compartibele with spe
% structures
n_accum_runs = 0;
for i_spe=1:numel(exper_info)
    n_accum_runs  = n_accum_runs+exper_info{i_spe}.n_runs;
end
hstruct = cell2struct(cell(numel(comp_fields),n_accum_runs),comp_fields);
header_out = cell(1,n_accum_runs);
all_samp = cell(n_accum_runs,1);
all_inst = cell(n_accum_runs,1);
ic = 1;
for i_head=1:numel(exper_info)
    exp = exper_info{i_head}.expdata;
    for j_e = 1:numel(exp)
        exp_j = exp(j_e);
        exp_j.angular_units = 'deg';
        header_out{ic} = exp_j;
        for j=1:n_comp_fields
            fld = comp_fields{j};
            val = exp_j.(fld);
            if ~istext(val)
                val = single(val);
            end
            hstruct(ic).(fld) = val ;
        end
        all_samp{ic} = exper_info{i_head}.samples(j_e);
        all_inst{ic} = exper_info{i_head}.instruments(j_e);
        ic = ic+1;
    end
end
[hstruct_sort,indh]=sortStruct(hstruct,comp_fields);


% % Find the entries in pstruct_sort that also appear in hstruct_sort
i_spe=1; j_hdr=1; n_spe=numel(pstruct_sort); n_exp=numel(hstruct_sort);
pcommon=false(n_spe,1); hcommon=false(n_exp,1);
tol = 2.0e-7;    % test number to define equality allowing for rounding errors (recall header fields were saved only as float32)
while (i_spe<=n_spe && j_hdr<=n_exp)
    if equal_to_tol(pstruct_sort(i_spe),hstruct_sort(j_hdr),-tol,'min_denominator',1)
        pcommon(i_spe)=true;
        hcommon(j_hdr)=true;
        i_spe  =i_spe+1;
        j_hdr  =j_hdr+1;
    else
        [~,tmpind]=sortStruct([pstruct_sort(i_spe),hstruct_sort(j_hdr)],comp_fields);
        if tmpind(1)==1
            i_spe=i_spe+1;
        else
            j_hdr=j_hdr+1;
        end
    end
end
ip0=indp(pcommon); ih0=indh(hcommon);   % indicies of the common entries in the original structure arrays
% Check that the fields that are required to be equal are indeed
for i_spe=1:numel(ip0)
    ok = equal_to_tol(pstruct(ip0(i_spe)),hstruct(ih0(i_spe)),tol);
    if ~ok
        error('HORACE:gen_sqw:invalid_argument',...
            'spe data for header %d and header of sqw file %d are inconsistent',...
            ip0(i_spe),ih0(i_spe));

    end
    ok = isequal(sample(ip0(i_spe)),all_samp{ih0(i_spe)});
    if ~ok
        error('HORACE:gen_sqw:invalid_argument',...
            'spe data and header of sqw file have inconsistent sample information')
    end
    ok = isequal(instrument(ip0(i_spe)),all_inst{ih0(i_spe)});   % we require the instrument is also equal
    if ~ok
        error('HORACE:gen_sqw:invalid_argument',...
            'spe data and header of sqw file have inconsistent instrument information');
    end
end
spe_only       =true(n_spe,1);
head_only      =true(n_exp,1);
spe_only(ip0)  =false;
head_only(ih0) =false;
