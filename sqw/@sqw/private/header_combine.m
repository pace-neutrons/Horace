function [header_out,nspe,ok,mess,hstruct_sort,ind] = header_combine(header,varargin)
% Combine header blocks to form a single block
%
%   >> [header_out,nfiles,ok,mess] = header_combine(header)
%
% Input:
% ------
%   header      Cell array of header blocks from a number of sqw files
%               Each header block is structure (single spe file) or a cell
%               array of single structures.
%               The special case of a single header block from a single spe
%               file being passed as a structure is allowed.
%   varargin    If present can be the keyword 'allow_equal_headers',
%               which disables checking input files for absolutely
%               equal headers. Two input files with equal haders is an error
%               in normal operations so this option  used in
%               tests only.

%
% Output:
% -------
%   header_out  Header block for a single sqw file that combines all the input
%              sqw files. (Note that if a single spe file, this is a structure
%              otherwise it is a cell array. This is the standard format for
%              an sqw file.) [column vector]
%   nspe        Array of length equal to the number of input header blocks containing
%              the number of spe files in each input header block [column vector]
%   ok          True if no problems combining, false otherwise
%   mess        Error message if not ok; equal to '' if ok
%   hstruct_sort Structure with the fields that define uniqueness of a header entry
%   ind         Index of hstruct_sort of equivalent entry in header_out
%
%
% Notes:
% ------
% 1) For the headers to be combined:
%    - The headers when left with the following subset of fields must be unique (that is,
%      the structure made from these fields must be unique)
%           fullfile(filepath,filename), efix, psi, omega, dpsi, gl, gs
%    - The contents of the following fields must be identical in all headers:
%           emode, alatt, angdeg, cu, cv, uoffset, u_to_rlu, ulen, sample
%    - Equality or otherwise of these fields is irrelevant:
%           en, ulabel, instrument
%
%  *** Should insist that the structure of instrument is the same in all headers
%      although the values of fields in nested structures and arrays can be different
%
% 2) The purpose of this routine is not to check the validity of the values of the
%   fields (e.g. that lattice parameters are greater than zero), but instead to
%   check the consistency of the equality or otherwise of the fields as required by later
%   algorithms in Horace

hstruct=struct('filename','','efix',[],'psi',[],'omega',[],'dpsi',[],'gl',[],'gs',[]);

drop_subz_headers = false;
if ismember('drop_subzones_headers',varargin)
    drop_subz_headers = true;
end

nsqw=numel(header);

% Catch case of a single header block from a single spe file - no processing required.
if isstruct(header) && nsqw==1
    header_out=header;
    nspe=1;
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

% Get number of elements in each header block
nspe=zeros(nsqw,1);
for i=1:nsqw
    if ~iscell(header{i})
        nspe(i)=1;
    else
        nspe(i)=numel(header{i});
    end
end
%
    function is=is_subzone_header(hd)
        % identify if this header belong to zone divided into subzones or not
        %
        % a first subzone header assumed not to belong to subzone headers
        [numbers,~] = regexp(hd.filepath,'\d*','match','split');
        num = str2double(numbers(3));
        if num>1
            is = true;
        else
            is = false;
        end
    end



% Construct output header block
nfiles_tot=sum(nspe);
header_out=cell(nfiles_tot,1);
ibeg=1;
for i=1:nsqw
    subz_header = false;
    
    if nspe(i)==1
        header_out(ibeg)=header(i);   % header for a single file is just a structure
        ibeg=ibeg+1;
        if drop_subz_headers
            subz_header = is_subzone_header(header(i));
        end        
    else
        header_out(ibeg:ibeg+nspe(i)-1)=header{i};    % header for more than one file is a cell array
        if drop_subz_headers
            subz_header = is_subzone_header(header_out{ibeg});
        end        
        ibeg=ibeg+nspe(i);
    end
    if subz_header
        nspe(i) = -nspe(i);
    end
end

if drop_subz_headers
    subzone_headers = cellfun(@(hd)(is_subzone_header(hd)),header_out);
    header_out = header_out(~subzone_headers);
end

% Check the headers are all unique across the relevant fields, and have equality in other required fields
% -------------------------------------------------------------------------------------------------------
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
reject_equal_headers = true;
if nargin>1 && strcmp(varargin{1},'allow_equal_headers')
    reject_equal_headers = false;
end

% Sort structure array
[hstruct_sort,ind]=nestedSortStruct(hstruct,names');
tol = 2.0e-7;    % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
for i=2:nfiles_tot
    if reject_equal_headers && isequal(hstruct_sort(i-1),hstruct_sort(i))
        header_out=cell(0,1); nspe=[]; ok=false; hstruct_sort=struct([]); ind=[];
        mess='At least two headers have the all the same filename, efix, psi, omega, dpsi, gl and gs'; return
    end
    ok = (header_out{i}.emode==header_out{1}.emode);
    ok = ok & equal_to_relerr(header_out{i}.alatt, header_out{1}.alatt, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.angdeg, header_out{1}.angdeg, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.cu, header_out{1}.cu, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.cv, header_out{1}.cv, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.uoffset, header_out{1}.uoffset, tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.u_to_rlu(:), header_out{1}.u_to_rlu(:), tol, 1);
    ok = ok & equal_to_relerr(header_out{i}.ulen, header_out{1}.ulen, tol, 1);
    if ~ok
        header_out=cell(0,1); nspe=[]; hstruct_sort=struct([]); ind=[];
        mess=['Not all input files have the same values for energy mode (0,1,2), lattice parameters,',...'
            'projection axes and projection axes offsets in the header blocks'];
        return
    end
    ok = isequal(header_out{i}.sample, header_out{1}.sample);
    if ~ok
        header_out=cell(0,1); nspe=[]; hstruct_sort=struct([]); ind=[];
        mess='Not all input files have the same fields or values of the fields in the sample in the header blocks';
        return
    end
end

% Final output
ok=true;
mess='';
end
