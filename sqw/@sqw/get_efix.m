function varargout = get_efix(varargin)
% Return the mean fixed neutron energy and emode for an array of sqw objects.
%
%   >> [efix,emode,ok,mess,en] = get_efix(win)
%   >> [efix,emode,ok,mess,en] = get_efix(win,tol)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%   tol         [Optional] acceptable relative spread w.r.t. average:
%                   max(|max(efix)-efix_ave|,|min(efix)-efix_ave|) <= tol*efix_ave
%
% Output:
% -------
%   efix        Fixed neutron energy (meV) (=NaN if not all data sets have the same emode)
%   emode       Value of emode (1,2 for direct, indirect inelastic; =0 elastic)
%              All efix must have the same emode. (emode returned as NaN if not the case)
%   ok          Logical flag: =true if within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   en          Structure with various information about the spread
%                   en.efix     array of all efix values, as read from sqw objects
%                   en.emode    array of all emode values, as read from sqw objects
%                   en.ave      average efix (same as output argument efix)
%                   en.min      minimum efix
%                   en.max      maximum efix
%                   en.relerr   larger of (max(efix)-efix_ave)/efix_ave
%                               and abs((min(efix)-efix_ave))/efix_ave
%                 (If emode not the same for all data sets, ave,min,max,relerr all==NaN)

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end


% Perform operations
% ------------------
tol_default=5e-3;
if numel(args)==1 && isnumeric(args{1}) && isscalar(args{1}) && args{1}>=0
    tol=args{1};
elseif numel(args)==0
    tol=tol_default;    % relative tolerance of spread of incident energies
else
    error('Check optional fractional tolerance is a non-negative scalar')
end

% Check that the data has the correct type
if ~all(w.sqw_type(:))
    error('efix and emode can only be retrived from sqw-type data')
end

source_is_file=w.source_is_file;
nobj=numel(w.data);     % number of sqw objects or files
nfiles=w.nfiles;
nend=cumsum(nfiles(:));
nbeg=nend-nfiles(:)+1;
efix_arr=zeros(nend(end),1);
emode_arr=zeros(nend(end),1);
for i=1:nobj
    if source_is_file
        ld = w.loaders_list{i};
        header = ld.get_header('-all');
    else
        header=w.data(i).header;
    end
    [efix_arr(nbeg(i):nend(i)),emode_arr(nbeg(i):nend(i))]=get_efix_single(header);
end

en=struct('efix',efix_arr,'emode',emode_arr,'ave',NaN,'min',NaN,'max',NaN,'relerr',NaN);
if all(emode_arr==emode_arr(1))
    efix=sum(efix_arr)/numel(efix_arr);
    emode=emode_arr(1);
    en.ave=efix;
    en.min=min(efix_arr);
    en.max=max(efix_arr);
    if en.ave==0 && en.min==0 && en.max==0
        en.relerr=0;    % if all energies==0, then accept this as no relative error
    else
        en.relerr=max(en.max-efix,efix-en.min)./efix;
    end
    if isfinite(en.relerr) && abs(en.relerr)<=tol
        ok=true;
        mess='';
    else
        ok=false;
        mess=['Spread of efix lies outside acceptable fraction of average of ',num2str(tol)];
    end
else
    efix=NaN;
    emode=NaN;
    ok=false;
    mess='All datasets must have the same value of emode (1=direct inelastic , 2=indirect inelastic; 0=elastic)';
end


% Set return arguments
argout{1}=efix;
argout{2}=emode;
argout{3}=ok;
argout{4}=mess;
argout{5}=en;


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end


%------------------------------------------------------------------------------
function [efix,emode]=get_efix_single(header)
% Get array of efix and emode for a single sqw object header
if ~iscell(header)
    efix=header.efix;
    emode=header.emode;
else
    nrun=numel(header);
    efix=zeros(nrun,1);
    emode=zeros(nrun,1);
    for i=1:nrun
        efix(i)=header{i}.efix;
        emode(i)=header{i}.emode;
    end
end
