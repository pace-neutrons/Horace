function varargout = get_mod_pulse(varargin)
% Get moderator pulse model name and mean pulse parameters for an array of sqw objects
%
%   >> [pulse_model,pp,ok,mess,p,present] = get_mod_pulse (win)
%   >> [pulse_model,pp,ok,mess,p,present] = get_mod_pulse (win,tol)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%   tol         [Optional] acceptable relative spread w.r.t. average of moderator
%              pulse shape parameters: maximum over all parameters of
%                   max(|max(p)-p_ave|,|min(p)-p_ave|) <= tol
%
% Output:
% -------
%   pulse_model Name of moderator pulse shape model e.g. 'ikcarp'
%              Must be the same for all data sets in all sqw objects
%             (Returned as [] if not all the same pulse model or length of
%              pulse parameters array not all the same)
%   pp          Mean moderator pulse shape parameters (numeric row vector)
%             (Returned as [] if not all the same pulse model or length of
%              pulse parameters array not all the same)
%   ok          Logical flag: =true if all parameters within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   p           Structure with various information about the spread
%                   p.pp       array of all parameter values, one row per data set
%                   p.ave      average parameter values (row vector)
%                             (same as output argument pp)
%                   p.min      minimum parameter values (row vector)
%                   p.max      maximum parameter values (row vector)
%                   p.relerr   larger of (max(p)-p_ave)/p_ave
%                               and abs((min(p)-p_ave))/p_ave
%                 (If pulse model or not all the same, or number of parameters
%                  not the same for all data sets, ave,min,max,relerr all==[])
%   present     True if a moderator is present in all sqw objects; false otherwise


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


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
    tol=tol_default;    % relative tolerance of spread of pulse shape parameters
else
    error('Check optional fractional tolerance is a non-negative scalar')
end

% Check that the data has the correct type
if ~all(w.sqw_type(:))
    error('moderator pulse parameters can only be retrived from sqw-type data')
end

% Get values
source_is_file=w.source_is_file;
nobj=numel(w.data);     % number of sqw objects or files
nfiles=w.nfiles;
nend=cumsum(nfiles(:));
nbeg=nend-nfiles(:)+1;
for i=1:nobj
    if source_is_file
        ld = w.loaders_list{i};
        header = ld.get_header('-all');        
    else
        header=w.data(i).header;
    end
    if i==1
        [pulse_model,pars,ok,mess,present]=get_mod_pulse_single(header);
        if ok   % construct array to hold all the pulse parameters
            np=size(pars,2);
            pp_arr=zeros(nend(end),np);
            pp_arr(nbeg(1):nend(1),:)=pars;
        end
    else
        [pulse_model_tmp,pars,ok_tmp,mess_tmp,present_tmp]=get_mod_pulse_single(header);
        ok=(ok && ok_tmp && strcmpi(pulse_model,pulse_model_tmp) && size(pars,2)==np);
        present=(present & present_tmp);
        if ok
            pp_arr(nbeg(i):nend(i),:)=pars;
        elseif isempty(mess)    % do not override an existing error message
            mess=mess_tmp;
        end
    end
end

p=struct('pp',[],'ave',[],'min',[],'max',[],'relerr',[]);
if ok
    p.pp=pp_arr;
    p.ave=mean(pp_arr,1);
    p.min=min(pp_arr,[],1);
    p.max=max(pp_arr,[],1);
    tmp=~(p.ave==0 & p.min==0 & p.max==0);
    p.relerr=zeros(size(p.ave));
    p.relerr(tmp)=max([p.max(tmp)-p.ave(tmp);p.ave(tmp)-p.min(tmp)],[],1)./p.ave(tmp);
    if any(p.relerr>=tol)
        ok=false;
        mess=['Spread of one or more pulse parameters lies outside acceptable fraction of average of ',num2str(tol)];
    end
    pp=p.ave;
else
    pulse_model='';
    pp=[];
end

% Set return arguments
argout{1}=pulse_model;
argout{2}=pp;
argout{3}=ok;
argout{4}=mess;
argout{5}=p;
argout{6}=present;


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end


%------------------------------------------------------------------------------
function [pulse_model,pp,ok,mess,present]=get_mod_pulse_single(header)
% Get moderator pulse model name and array of pulse parameters for a single sqw object header
%
%   >> [pulse_model,pp,ok,mess,present] = get_mod_pulse_single (header)
%   >> [pulse_model,pp,ok,mess,present] = get_mod_pulse_single (header,tol)
%
% Input:
% ------
%   header      Header block in an sqw object or file (must be sqw type)
%   tol         [Optional] acceptable relative spread w.r.t. average of moderator
%              pulse shape parameters: maximum over all parameters of
%                   max(|max(p)-p_ave|,|min(p)-p_ave|) <= tol
%
% Output:
% -------
%   pulse_model Name of moderator pulse shape model e.g. 'ikcarp'
%              Must be the same for all data sets in all sqw objects; set to '' if
%              pulse_model not all the same, or the number of parameters not all the same
%   pp          Moderator pulse shape parameters (one row per spe data set); set to '' if
%              pulse_model not all the same, or the number of parameters not all the same
%   ok          Logical flag: =true if within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   present     True if a moderator is present; false otherwise

    
% Get array of moderator objects from the header
if ~iscell(header), header = {header}; end  % for convenience
nrun=numel(header);
moderator = repmat(IX_moderator,nrun,1);
present = false;
for i=1:nrun
    try
        moderator(i) = header{i}.instrument.moderator;
    catch
        pulse_model=''; pp=[]; ok=false;
        mess='IX_moderator object not found in all instrument descriptions';
        return
    end
end
present = true;

% Fill output
if numel(moderator)==1
    pulse_model=moderator.pulse_model;
    pp=moderator.pp;
else
    pulse_model=moderator(1).pulse_model;
    pp=repmat(moderator(1).pp(:)',nrun,1);  % ensure one row per spe data set
    np=size(pp,2);
    for i=2:nrun
        if strcmp(moderator(i).pulse_model,pulse_model) && numel(moderator(i).pp)==np
            pp(i,:)=moderator(i).pp(:)';
        else
            pulse_model=''; pp=[]; ok=false;
            mess='Moderator pulse names and/or number of pulse parameters are not the same for all contributing data sets';
            return
        end
    end
end

ok=true;
mess='';

