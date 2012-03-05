function var = gget (nam)
% Retrieve information for the named variable from an ISIS raw file
%
%   >> var=gget(name)
%   >> var=gget         % return default data source
%
% Name can be one of the valid field names in a raw file, or one of the custom
% synonymns defined in mgenie for convenience
%
% E.g.
%   >> ntc = gget('ntc1')           % number of time channels
%   >> uahr = gget('good_charge')   % uA.hr (equivalent to:  >> tmp=gget('RRPB'); >> uahr=tmp(8))
%   >> cnts = gget('cnt1[101:200]') % raw counts in spectra 101 to 200 returned as an array

global mgenie_globalvars

isisraw=mgenie_globalvars.isisraw;

% No argument: get default data source
% ------------------------------------
if nargin==0
    var=genie_getvalue;
    return
end

% Check NAM is a single character string
% ----------------------------------------
if ~isstring(nam) || isempty(nam)
    error ('Input field name must be a character array')
end

% Is NAM a valid raw file field name ?
% -------------------------------------
if any(strcmpi(nam,isisraw.field.name))
    var = genie_getvalue(nam);
    return
end

% Is NAM of the form CNT1[m:n] ? (i.e. read a section of the CNT1 array)
% ------------------------------
if numel(nam)>=9 && strcmpi(nam(1:5),'cnt1[') && nam(end:end)==']'                  % has format cnt1[xx:xx]
    nspec = double(genie_getvalue('nper'))*(double(genie_getvalue('nsp1'))+1) - 1;  % maximum spsectrum number in a multi-period run
    ipos = strfind(nam,':');
    if isscalar(ipos)
        islo = str2double(nam(6:ipos-1));
        ishi = str2double(nam(ipos+1:end-1));
        if ~isnan(islo) && ~isnan(ishi) && islo>=1 && ishi<=nspec && islo<=ishi
            var = genie_getvalue(nam);
            return
        end
    end
    error (['Count array section must have form CNT1[m:n], with 0 =< m =< n =< ',num2str(nspec)])
end

% Is NAM a valid derived raw file field ?
% ---------------------------------------
% User tables for detector information:
if numel(nam)>2 && strncmpi(nam,'ut',2) && ~isnan(str2double(nam(3:end)))  % NAM starts with the two letters UT, and the rest is a number
    n = str2double(nam(3:end));
    nuse=genie_getvalue('nuse');
    if n>=1 && n<=nuse % table number in range 1 to NUSE
        var = genie_getvalue(nam);
        return
    else
        error (['User table entries must have form UTnn with nn in the range 1 to ',num2str(nuse)])
    end
end

% Sample environment block information: check if NAM starts with SE, RSE or CSE, and that the rest is a number
if numel(nam)>2 && strncmpi(nam,'se',2) && ~isnan(str2double(nam(3:end)))
    n = str2double(nam(3:end));
elseif numel(nam)>3 && (strncmpi(nam,'rse',3) || strncmpi(nam,'cse',3)) && ~isnan(str2double(nam(4:end)))
    n = str2double(nam(4:end));
else
    n=0;
end
if n~=0
    nsep=genie_getvalue('nsep');
    if n>=1 && n<=nsep  % table number in range 1 to NSEP
        var = genie_getvalue(nam);
        return
    else
        error (['If of form SEnn/RSEnn/CSEnn then must have nn in the range 1 to ',num2str(nsep)])
    end
end

% Determine if NAM is not in the RAW file field definitions, but is defined in gget_init as a valid name
% --------------------------------------------------------------------------------------------------------
% (Many fields in the raw file are obscure e.g. uA.hr is in RRPB(8) !)

% Is NAM in HEADER section ?
ind = find(strcmpi(nam,isisraw.hdr.name),1);
if ~isempty(ind)
    temp = genie_getvalue('hdr');
    var = temp(isisraw.hdr.begin(ind):isisraw.hdr.end(ind));
    return
end

% Is NAM in RUN section ?
ind = find(strcmpi(nam,isisraw.run.name),1);
if ~isempty(ind)
    temp = genie_getvalue(isisraw.run.raw_name{ind});
    var = temp(isisraw.run.index(ind));
    if iscellstr(var) && numel(var)==1  % if a cellstr with a single entry, then convert to character string
        var = char(var);
    end
    return
end

% Any other custom names dealt with on a case-by-case basis:
% ----------------------------------------------------------
if strcmpi(nam,'tchan1')    % return time channel boundaries in microseconds
    daep = genie_getvalue('daep');
    pre1 = genie_getvalue('pre1');
    var = (double(pre1).*double(genie_getvalue('tcb1')) + 128*double(daep(24)))/32;
    return
end

if strcmpi(nam,'dtchan1')   % return widths of time channel boundaries in microseconds
    pre1 = genie_getvalue('pre1');
    temp = double(genie_getvalue('tcb1'));
    var = (double(pre1)/32).*(temp(2:end)-temp(1:end-1));
    return
end

% Not a valid variable name
% ----------------------------
error ('Unrecognised ISIS raw data field name')
