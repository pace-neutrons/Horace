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
sz = obj.dims_as_ssize;

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


