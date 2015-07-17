function [ok, type, mess] = check_sqw_data_(data, type_in, field_names_only)
% Check that the fields in the data are OK
%
%   >> [ok, mess] = check_sqw_data (data)
%   >> [ok, mess] = check_sqw_data (data, type_in)
%   >> [ok, mess] = check_sqw_data (data, type_in, fields_names_only)
%
% Input:
% ------
%   data        Structure to be tested
%   type_in     Test valid instance of specified type
%               'a'     full sqw-type data structure
%               'b+'    dnd-type data structure
%               If empty or absent, permit either
%   fields_names_only
%               If=true, check field names only
%                 =false or empty or absent, check all fields of permitted type(s)
%
% Output:
% -------
%   ok          OK=true if valid, OK=false if not
%   type        type='b+' if no pixel information (i.e. 'dnd' case);
%               type='a' if full pixel information (i.e. 'sqw' type)
%               If not OK, then type=''
%   mess        if OK, then empty string; if ~OK contains error message

% Original author: T.G.Perring
%
% $Revision: 1019 $ ($Date: 2015-07-16 12:20:46 +0100 (Thu, 16 Jul 2015) $)

%fields_a = {'filename';'filepath';'title';'alatt';'angdeg';'uoffset';'u_to_rlu';'ulen';'ulabel';'iax';'iint';...
%    'pax';'p';'dax';'s';'e';'npix';'urange';'pix';'axis_caption'}; % column

%fields_bplus = {'filename';'filepath';'title';'alatt';'angdeg';'uoffset';'u_to_rlu';'ulen';'ulabel';'iax';'iint';...
%    'pax';'p';'dax';'s';'e';'npix';'axis_caption'}; % column

ok=false;
type='';
mess='';

% Check input options flags - these better be OK if Horace is written correctly
if ~exist('type_in','var')||isempty(type_in)
    type_in = [];
elseif ~(isequal(type_in,'a')||isequal(type_in,'b+'))
    error('Invalid argument type_in to check_sqw_data - logic problem in Horace')
end
if ~exist('field_names_only','var')||isempty(field_names_only)
    field_names_only = false;
elseif ~(isnumeric(field_names_only)||islogical(field_names_only))
    error('Invalid argument field_names_only to check_sqw_data - logic problem in Horace')
end



if isempty(data.p) || isempty(data.urange)
   tmp_type='b+';
else
    tmp_type='b+';    
end
%fndata = fieldnames(data);
% HACK!
%all_members_ind = ismember(fndata,'axis_caption');
%if any(all_members_ind)
%    fndata = fndata(~all_members_ind);
%end

% Check data argument
% ---------------------
% Check field names
%if isequal(fndata,fields_a) && (isempty(type_in)||strcmpi(type_in,'a'))
%    tmp_type='a';
%elseif isequal(fndata,fields_bplus) && (isempty(type_in)||strcmpi(type_in,'b+'))
%    tmp_type='b+';
%else
%    mess='Data is not a structure with required fields'; return
%end


if ~field_names_only
    % Check contents of fields
    % ------------------------
    % Not exhaustive, as doesn't check numerical values in the main
    if ~is_string_or_empty_string(data.filename), mess='ERROR: Field ''filename'' must be a character string'; return; end
    if ~is_string_or_empty_string(data.filepath), mess='ERROR: Field ''filepath'' must be a character string'; return; end
    if ~is_string_or_empty_string(data.title), mess='ERROR: Field ''title'' must be a character string'; return; end
    if ~isa_size(data.alatt,'vector','double')
        mess='ERROR: Field ''alatt'' must be a numeric vector length 3'; return; end
    if ~isa_size(data.angdeg,'vector','double'), mess='ERROR: Field ''angdeg'' must be a numeric vector length 3'; return; end
    if ~isa_size(data.uoffset,[4,1],'double'); mess='ERROR: field ''uoffset'' must be a column vector of 4 numbers'; return; end
    if data.uoffset(4)~=0; mess='ERROR: Energy offset ''uoffset(4)'' must be zero'; return; end
    if ~isa_size(data.u_to_rlu,[4,4],'double'); mess='ERROR: field ''u_to_rlu'' must be a 4x4 matrix of numbers'; return; end
    if ~isa_size(data.ulen,[1,4],'double'); mess='ERROR: field ''ulen'' must be a row vector of 4 numbers'; return; end
    if ~isa_size(data.ulabel,[1,4],'cellstr'); mess='ERROR: field ''ulabel'' must be a (row) cell array of 4 strings'; return; end

    if ~isempty(data.iax) && ~isa_size(data.iax,'row','double')
        mess='ERROR: field ''iax'' must be a row vector of integration axis indicies'; return; end
    if ~isempty(data.pax) && ~isa_size(data.pax,'row','double')
        mess='ERROR: field ''pax'' must be a row vector of plot axis indicies'; return; end
    if ~isempty(data.iax) && ~isempty(data.pax)
        if ~isequal(sort([data.pax,data.iax]),[1,2,3,4])
            mess='ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4'; return; end
        ndim=numel(data.pax);
    elseif isempty(data.iax)
        if ~isequal(sort([data.pax]),[1,2,3,4])
            mess='ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4'; return; end
        ndim=4;
    elseif isempty(data.pax)
        if ~isequal(sort([data.iax]),[1,2,3,4])
            mess='ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4'; return; end
        ndim=0;
    else
        mess='ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4'; return
    end

    if ndim~=4
        if ~isa_size(data.iint,[2,4-ndim],'double') || any(diff(data.iint,1)<0)
            mess='ERROR: field ''iint'' must be a [2 x (4-ndim)] vector of integration ranges'; return; end
    else
        if ~isempty(data.iint)
            mess='ERROR: field ''iint'' must be empty or a [2 x 0] vector of integration ranges'; return; end
    end

    if ndim~=0
        if ~iscell(data.p) || ~isequal(size(data.p),[1,ndim])
            mess='ERROR: field ''p'' must be a [1 x ndim)] cell array of bin boundary arrays'; return; end
        sz=zeros(1,ndim);
        for i=1:ndim
            if ~isa_size(data.p{i},'column','double') || size(data.p{i},1)<2 || ...
                    ((numel(data.p{i})>2 && min(diff(data.p{i}))<=0)||(numel(data.p{i})==2 && min(diff(data.p{i}))<0))
                    % allow case of two bin boundaries that are equal
                mess='ERROR: Bin boundaries for plot axes must be strictly monotonic increasing';
                return
            end
            sz(i)=numel(data.p{i})-1;
        end
        if ndim==4 && isequal(sz(3:4),[1,1])
            sz=sz(1:2);
        elseif ndim==4 && sz(4)==1
            sz=sz(1:3);
        elseif ndim==3 && sz(3)==1;
            sz=sz(1:2);
        elseif ndim==1;
            sz=[sz,1];   % expand size array for one dimensional case
        end
        if ~isa_size(data.dax,'row','double')||~isequal(sort(data.dax),1:ndim)
            mess='ERROR: field ''dax'' must be a row vector length ndim indexing a permutation of the plot axes';
            return
        end
    else
        if ~isempty(data.p); mess='ERROR: field ''p'' must be empty'; return; end
        if ~isempty(data.dax); mess='ERROR: field ''dax'' must be empty'; return; end
        sz=[1,1];   % expected size of a zero-dimensional sqw object signal array
    end

    if ~isa_size(data.s,sz,'double'); mess='ERROR: field ''s'' must have size matching bins along plot axes'; return; end
    if ~isa_size(data.e,sz,'double'); mess='ERROR: field ''e'' must have size matching bins along plot axes'; return; end
    if any(data.e<0); mess='ERROR: field ''e'' must not have negative elements (it holds variances)'; return; end
    if ~isa_size(data.npix,sz,'numeric')
        mess='ERROR: field ''npix'' must have size matching bins along plot axes'; return; end
    if any(data.npix<0)
        mess='ERROR: field ''npix'' must not have negative elements'; return; end

    if tmp_type=='a'    % extra fields required for sqw object
        npixtot=sum(data.npix(:));
        if ~npixtot==0
            if ~isa_size(data.urange,[2,4],'double') || any(diff(data.urange,1)<0)
                mess='ERROR: field ''urange'' must be a 2x4 array of ranges'; return; end
        else
            if ~isequal(data.urange,[Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf])  % convention if no pixels
                mess='ERROR: field ''urange'' must be a [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf] if no pixels in range of sqw object'; return; end
        end
        % There are many check that could (perhaps should) be performed on pix, but could be very time consuming
        if ~isa_size(data.pix,[9,npixtot])
            mess='ERROR: field ''pix'' must be 9 x npixtot array of pixel information'; return; end
    end
end

% Ok if got to here
ok=true;
type=tmp_type;


%==================================================================================================
function ok = is_string_or_empty_string(arg)
% Check if argument is a row character string, or an empty string
if ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1)
    ok=true;
else
    ok=false;
end
