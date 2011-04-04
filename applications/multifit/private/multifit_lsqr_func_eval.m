function varargout=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pf,pinfo)
% Calculate the intensities and variances for the data in multifit.
%
%  Evaluate function and store values:
%   >> multifit_lsqr_func_eval     % cleanup stored arguments
%   >> [ycalc,var]=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pf,pinfo))  
%
% The option to call with just the masking is there to ensure that one function only needs to be altered
% should the format of the input data object, w, is changed.
%
% Stores values from earlier evaluations to minimise function re-evaluations

persistent store_filled pstore bpstore fcalc fvar bcalc bvar


% Cleanup if requested
% -----------------------
if nargin==0
    store_filled=[];
    pstore=[]; bpstore=[];
    fcalc=[]; fvar=[]; bcalc=[]; bvar=[];
    return
end


% Function evluation requested
% ----------------------------
if isempty(store_filled)
    fcalc=cell(size(w)); fvar=cell(size(w)); bcalc=cell(size(w)); bvar=cell(size(w));
    for i=1:numel(w)
        if xye(i)
            fvar{i}=zeros(size(w{i}.y));
            bvar{i}=zeros(size(w{i}.y));
        end
    end
end

% Get latest numerical parameters
[p,bp]=ptrans(pf,pinfo);

% Update global function calculated values
if isempty(store_filled) || ~isequal(p,pstore)
%     disp([p(:)';pstore(:)'])
    pstore=p;
    pars=parameter_set(pin,p);
    if ~iscell(pars), pars={pars}; end  % make a cell for convenience
    for i=1:numel(w)
        if xye(i)
            fcalc{i}=func(w{i}.x{:},pars{:});
        else
            wcalc=func(w{i},pars{:});
            [fcalc{i},fvar{i},msk]=sigvar_get(wcalc);
            fcalc{i}=fcalc{i}(msk);         % remove the points that we are told to ignore
            fvar{i}=fvar{i}(msk);
        end
        fcalc{i}=fcalc{i}(:);   % make column vector
        fvar{i}=fvar{i}(:);
    end
end

% Update background function calculation
for i=1:numel(w)
    if isempty(store_filled) || ~isequal(bp{i},bpstore{i})
        bpstore{i}=bp{i};
        if ~isempty(bkdfunc{i})
            pars=parameter_set(bpin{i},bp{i});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            if xye(i)
                bcalc{i}=bkdfunc{i}(w{i}.x{:},pars{:});
            else
                wcalc=bkdfunc{i}(w{i},pars{:});
                [bcalc{i},bvar{i},msk]=sigvar_get(wcalc);
                bcalc{i}=bcalc{i}(msk);         % remove the points that we are told to ignore
                bvar{i}=bvar{i}(msk);
            end
            bcalc{i}=bcalc{i}(:);   % make column vector
            bvar{i}=bvar{i}(:);
        else    % empty background function element means no background function
            bcalc{i}=zeros(size(fcalc{i}));
            bvar{i}=zeros(size(fvar{i}));
        end
    end
end

% Package data
varargout{1} = cell2mat(fcalc(:)) + cell2mat(bcalc(:));    % one long column vector
varargout{2} = cell2mat(fvar(:)) + cell2mat(bvar(:));      % one long column vector

% Update store flag
if isempty(store_filled)
    store_filled=1;
end
