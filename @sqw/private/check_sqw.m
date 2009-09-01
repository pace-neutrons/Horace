function [ok, mess, type, dout] = check_sqw (d, type_in)
% Check fields of a structure match those for a valid sqw object
%
%   >> [ok, mess, type, dout] = check_sqw (d, type_in)
%
% Input:
% ------
%   d       Input data structure. 
%   type_in     Test valid instance of specified type
%               'a'     full sqw-type data structure
%               'b+'    dnd-type data structure
%               If empty or absent, permit either
%
% Output:
% -------
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid sqw object, empty string if is valid.
%   type    type='b+' if no pixel information (i.e. 'dnd' case);
%           type='a' if full pixel information (i.e. 'sqw' type)
%               If not OK, then type=''
%   dout    Output data structure with valid fields
%           - Empty fields that are valid are converted to required form

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

% Not all checks are performed in some of the fields - see the individual
% check_sqw_* functions for more details.
% Does not yet ensure that the main_header.filename, filepath and title 
% match the corresponding fields in data.

fields = {'main_header';'header';'detpar';'data'};  % column

ok=false;
type='';
if nargout==4
    dout_required=true;
    dout=struct([]);
else
    dout_required=false;
end


% Check input options flags - these better be OK if Horace is written correctly
if ~exist('type_in','var')||isempty(type_in)
    type_in = [];
elseif ~(isequal(type_in,'a')||isequal(type_in,'b+'))
    error('Invalid argument type_in to check_sqw - logic problem in Horace')
end


% Check data argument
% -------------------
if ~isstruct(d) || ~isequal(fieldnames(d),fields)
    mess='Object is not a structure with required fields'; return
end


% Check main header is OK
% --------------------------
[ok,mess] = check_sqw_main_header(d.main_header);
if ~ok, mess=['main_header: ',mess]; return, end

if isempty(d.main_header) && (isempty(type_in)||strcmpi(type_in,'b+'))
    dnd_type=true;  % object can only be possibly be dnd type
    tmp_type='b+';
elseif (isempty(type_in)||strcmpi(type_in,'a'))
    dnd_type=false; % object can only be possibly be sqw type
    tmp_type='a';
else
    mess='Main header inconsistent with valid object'; return
end


% Check header(s)
% ---------------------
[ok,mess] = check_sqw_header(d.header);
if ~ok, mess=['header: ',mess]; return, end
if dnd_type && ~isempty(d.header)
    mess='header: header block inconsistent with main_header';
    return
end


% Check detector block
% -----------------------
[ok,mess] = check_sqw_detpar(d.detpar);
if ~ok, mess=['detpar: ',mess]; return, end
if dnd_type && ~isempty(d.detpar)
    mess='detpar: detector block inconsistent with main_header';
    return
end


% Check data block
% ---------------------
[ok,type,mess] = check_sqw_data(d.data,tmp_type);
if ~ok, mess=['data: ',mess]; return, end


% OK if got to here
% ---------------------
ok=true;


% If output data strcture, put empty fields into standard form
% -------------------------------------------------------------
% Want to fill with standard forms, even though we have been forgiving about
% entering empty fields when populating.

if dout_required
    dout=d;
    if isempty(d.data.iax) && ~isequal(d.data.iax,zeros(1,0))
        dout.data.iax=zeros(1,0);
    end
    if isempty(d.data.iint) && ~isequal(d.data.iint,zeros(2,0))
        dout.data.iint=zeros(2,0);
    end
    if isempty(d.data.pax) && ~isequal(d.data.pax,zeros(1,0))
        dout.data.pax=zeros(1,0);
    end
    if isempty(d.data.dax) && ~isequal(d.data.dax,zeros(1,0))
        dout.data.dax=zeros(1,0);
    end
    if isempty(d.data.p) && ~isequal(d.data.p,cell(1,0))
        dout.data.p=cell(1,0);
    end
end
