function [type,obj] = check_sqw_data_(obj, type_in)
% Check that the fields in the data are OK
%
%   >> [ok, mess] = check_sqw_data (data)
%   >> [ok, mess] = check_sqw_data (data, type_in)
%   >> [ok, mess] = check_sqw_data (data, type_in, fields_names_only)
%   >> [ok, mess,data] = check_sqw_data (...)
%
% Input:
% ------
%   data        Structure to be tested
%   type_in     Test valid instance of specified type
%               'a'     full sqw-type data structure
%               'b+'    dnd-type data structure
%               If empty or absent, permit either
%
% Output:
% -------
%   ok          OK=true if valid, OK=false if not
%   type        type='b+' if no pixel information (i.e. 'dnd' case);
%               type='a' if full pixel information (i.e. 'sqw' type)
%               If not OK, then type=''
%   mess        if OK, then empty string; if ~OK contains error message
%   data        if provided, allow to fix some data (e.g. type or
%               row-column distribution) automatically

% Original author: T.G.Perring
%
%
%fields_a = {'filename';'filepath';'title';'alatt';'angdeg';'uoffset';'u_to_rlu';'ulen';'ulabel';'iax';'iint';...
%    'pax';'p';'dax';'s';'e';'npix';'img_db_range';'pix';'axis_caption'}; % column

%fields_bplus = {'filename';'filepath';'title';'alatt';'angdeg';'uoffset';'u_to_rlu';'ulen';'ulabel';'iax';'iint';...
%    'pax';'p';'dax';'s';'e';'npix';'axis_caption'}; % column

% Check input options flags - these better be OK if Horace is written correctly
if ~exist('type_in','var')||isempty(type_in)
    type_in = [];
elseif ~(isequal(type_in,'a')||isequal(type_in,'b+') || ...
        isequal(type_in,'a-') || isequal(type_in,'b'))
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'Invalid argument type_in to check_sqw_data - logic problem in Horace')
end



if isempty(obj.pix)
    tmp_type='a-';
else
    if isempty(obj.img_db_range)
        tmp_type='b+';
    else
        if all(isinf(obj.img_db_range))
            tmp_type='a';
        else
            tmp_type='b+';
        end
    end
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



% Check contents of fields
% ------------------------
% Not exhaustive, as doesn't check numerical values in the main
if ~is_string_or_empty_string(obj.filename)
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Field ''filename'': must be a character string, actually it is %s',class(obj.filename));
end
if ~is_string_or_empty_string(obj.filepath)
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Field ''filepath'' must be a character string')
end
if ~is_string_or_empty_string(obj.title)
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Field ''title'' must be a character string');
end
if ~isa_size(obj.alatt,'vector','double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Field ''alatt'' must be a numeric vector length 3');
end
if ~isa_size(obj.angdeg,'vector','double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Field ''angdeg'' must be a numeric vector length 3');
end
if ~isa_size(obj.uoffset,[4,1],'double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''uoffset'' must be a column vector of 4 numbers');
end
if obj.uoffset(4)~=0
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: Energy offset ''uoffset(4)'' must be zero');
end
if ~isa_size(obj.u_to_rlu,[4,4],'double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''u_to_rlu'' must be a 4x4 matrix of numbers');
end
if ~isa_size(obj.ulen,[1,4],'double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''ulen'' must be a row vector of 4 numbers');
end
if ~isa_size(obj.ulabel,[1,4],'cellstr')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''ulabel'' must be a (row) cell array of 4 strings');
end

if ~isempty(obj.iax) && ~isa_size(obj.iax,'row','double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''iax'' must be a row vector of integration axis indicies');
end
if ~isempty(obj.pax) && ~isa_size(obj.pax,'row','double')
    obj.pax = double(obj.pax);
    if ~isa_size(obj.pax,'row','double')
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''pax'' must be a row vector of plot axis indicies');
    end
end
if ~isempty(obj.iax) && ~isempty(obj.pax)
    if ~isequal(sort([obj.pax,obj.iax]),[1,2,3,4])
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4');
    end
    ndim=numel(obj.pax);
elseif isempty(obj.iax)
    if ~isequal(sort([obj.pax]),[1,2,3,4])
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4');
    end
    ndim=4;
elseif isempty(obj.pax)
    if ~isequal(sort([obj.iax]),[1,2,3,4])
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4');
    end
    ndim=0;
else
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: fields ''iax'' and ''pax'' must collectively cover axes 1,2,3 and 4');
end

if ndim~=4
    if ~isa_size(obj.iint,[2,4-ndim],'double') || any(diff(obj.iint,1)<0)
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''iint'' must be a [2 x (4-ndim)] vector of integration ranges');
    end
    
else
    if ~isempty(obj.iint)
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''iint'' must be empty or a [2 x 0] vector of integration ranges');
    end
end

if ndim~=0
    if ~iscell(obj.p) || ~isequal(size(obj.p),[1,ndim])
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''p'' must be a [1 x ndim)] cell array of bin boundary arrays');
    end
    sz=zeros(1,ndim);
    for i=1:ndim
        if ~isa_size(obj.p{i},'column','double') || size(obj.p{i},1)<2 || ...
                ((numel(obj.p{i})>2 && min(diff(obj.p{i}))<=0)||(numel(obj.p{i})==2 && min(diff(obj.p{i}))<0))
            % allow case of two bin boundaries that are equal
            error('HORACE:data_sqw_dnd:invalid_argument',...
                'ERROR: Bin boundaries for plot axes must be strictly monotonic increasing');
        end
        sz(i)=numel(obj.p{i})-1;
    end
    if ndim==4 && isequal(sz(3:4),[1,1])
        sz=sz(1:2);
    elseif ndim==4 && sz(4)==1
        sz=sz(1:3);
    elseif ndim==3 && sz(3)==1
        sz=sz(1:2);
    elseif ndim==1
        sz=[sz,1];   % expand size array for one dimensional case
    end
    if ~isa_size(obj.dax,'row','double')||~isequal(sort(obj.dax),1:ndim)
        obj.dax = double(obj.dax);
        if ~isa_size(obj.dax,'row','double')
            error('HORACE:data_sqw_dnd:invalid_argument',...
                'ERROR: field ''dax'' must be a row vector length ndim indexing a permutation of the plot axes');
            
        end
        
    end
else
    if ~isempty(obj.p)
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''p'' must be empty');
    end
    if ~isempty(obj.dax)
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''dax'' must be empty');
    end
    sz=[1,1];   % expected size of a zero-dimensional sqw object signal array
end

if ~isa_size(obj.s,sz,'double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''s'' must have size matching bins along plot axes');
end
if ~isa_size(obj.e,sz,'double')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''e'' must have size matching bins along plot axes');
end
if any(obj.e<0)
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''e'' must not have negative elements (it holds variances)');
end
if ~isa_size(obj.npix,sz,'numeric')
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''npix'' must have size matching bins along plot axes');
end
if any(obj.npix<0)
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'ERROR: field ''npix'' must not have negative elements');
end

if tmp_type=='a'    % extra fields required for sqw object
    npixtot=sum(obj.npix(:));
    if ~npixtot==0
        if ~isa_size(obj.img_db_range,[2,4],'double') || (any(diff(obj.img_db_range,1)<0) && ~all(isinf(obj.img_db_range(:))))
            error('HORACE:data_sqw_dnd:invalid_argument',...
                'ERROR: field ''img_db_range'' must be a 2x4 array of ranges');
        end
        if all(isinf(obj.img_db_range(:)))
            tmp_type='b+';
        end
    else
        if ~isequal(obj.img_db_range,[Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf])  % convention if no pixels
            error('HORACE:data_sqw_dnd:invalid_argument',...
                'ERROR: field ''img_db_range'' must be a [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf] if no pixels in range of sqw object');
        else
            tmp_type='b+';
        end
    end
    % There are many check that could (perhaps should) be performed on pix, but could be very time consuming
    if ~isa_size(obj.pix,[9,npixtot]) && ~strcmp(tmp_type,'b+')
        error('HORACE:data_sqw_dnd:invalid_argument',...
            'ERROR: field ''pix'' must be 9 x npixtot array of pixel information');
    end
end


% Ok if got to here
type=tmp_type;


%==================================================================================================
function ok = is_string_or_empty_string(arg)
% Check if argument is a row character string, or an empty string
if ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1)
    ok=true;
else
    ok=false;
end

