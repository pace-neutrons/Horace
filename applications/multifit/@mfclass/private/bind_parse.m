function [ok,mess,ipb,ifunb,ipf,ifunf,R] = bind_parse(np,nbp,isfore,ifunb_def,bnd)
% Determine if a binding descriptor is valid
%
%   >> [ok,mess,ipf,ifunf,ipb,ifunb,R] = bind_parse(np,nbp,isfore,ifun_def,bnd)
%
% Input:
% ------
%   np          Number of parameters for each foreground function (row vector)
%   nbp         Number of parameters for each background function (row vector)
%   isfore      True if positive function index refers to foreground functions
%               False if positive function index refers to background functions
%   ifunb_def   Default function index for parameter to be bound. Reference
%              as foreground or background is determined by the value of isfore.
%                   Foreground function: in range 1 to numel(np)
%                   Background function: in range 1 to numel(nbp)
%               If there is no default set ifunb_def = []
%               If an array of default function indicies is given, then the
%              binding descrptor is evaluated for each index if the default is
%              used.
%
%   bnd         One of two forms:
%               (1) Cell array of binding descriptors {b1, b2,...}
%                   (or a scalar cell array containing this i.e. {{b1, b2,...}}
%               Valid forms for b1, b2,... are:
%                 If ifunb_def is given:
%                   {ipb,  ipf}
%                   {ipb, [ipf,ifun]}
%                 If ifunb_def is not given:
%                   {[ipb,ifunb],  ipf}             % assumes ifun is ifunb
%                   {[ipb,ifunb], [ipf,ifun]}
%               and with any of the above:
%                   {..., R}
%               The sign of functions is interpreted by the value of isfore.
%               If ifun_def is used to determine the function(s), then the sign
%              of ip can be negative; this inverts the sign of the functions.
%              This can be exploited to make it simple to make some global bindings
%              e.g. to bind parameter 3 of every foreground function
%
%               If b1,b2,.. are not all cell arrays, interpret as the elements
%               of a single binding descriptor with one of the forms above.
%
%               (2) Numeric array size [n,5] where n is the number of bindings
%                   (or a scalar cell array containing this)
%               Each row of the array contains:
%                   ipb         Parameter index within the functions for
%                              the bound parameters
%                   ifunb       Function indicies for the bound parameter
%                               - foreground functions: numbered 1,2,3,...numel(np)
%                               - background functions: numbered -1,-2,-3,...-numel(nbp)
%                   ipf         Parameter indicies within the functions for
%                              the floating parameters
%                   ifunf       Function index for the floating parameter
%                               - foreground functions: numbered 1,2,3,...numel(np)
%                               - background functions: numbered -1,-2,-3,...-numel(nbp)
%                   R           Ratio of values of bound/independent parameters (column vector).
%               If to be set by values of initial parameter values, then is NaN;
%              otherwise is finite.
%                   
%
% Output:
% -------
%   ok          True if binding descriptor is valid
%   mess        Error message if not ok; empty string or warning/informational
%              message if ok
%   ipb         Parameter indicies within the functions for the bound parameters
%              (column vector))
%   ifunb       Function indicies for the bound parameters (column vector):
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   ipf         Parameter indicies within the functions for the floating parameters
%   ifunf       Function index for the floating parameter(column vector):
%              (column vector))
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   R           Ratio of values of bound/independent parameters (column vector).
%               If to be set by values of initial parameter values, then is NaN;
%              otherwise is finite.


% Need to distinguish within a set of cases:
% -Called directly with binding arguments:
%   <empty>
%    numeric        numeric size [n,5]
%    b1             scalar cell array, nothing in it a cell array
%   {b1,b2,...}     cell array of cell arrays
%
% -Called from a function that provides a cell array of the passed arguments:
%   {}
%   {numeric}       scalar cell array with a numeric size [n,5]
%   {b1}            scalar cell array containing a cell array
%  {{b1}}           scalar cell array containing a scalar cell array
%  {{b1,b2,...}}    scalar cell array containing a cell array of cell arrays

if isempty(bnd)
    % Case of empty input, including {}
    ok=true;
    mess='';
    [ipb,ifunb,ipf,ifunf,R]=empty_return;   % just use to fill with suitable values
    return
    
elseif isnumeric(bnd) || (iscell(bnd) && numel(bnd)==1 && isnumeric(bnd{1}))
    % Case of numeric or {numeric} - so expecting a numeric array of binding descriptors
    if isnumeric(bnd)
        [ok,mess,ipb,ifunb,ipf,ifunf,R,self_rem] = bind_parse_array (np,nbp,isfore,bnd);
    else
        [ok,mess,ipb,ifunb,ipf,ifunf,R,self_rem] = bind_parse_array (np,nbp,isfore,bnd{1});
    end
    if ok && numel(ipf)==0 && self_rem
        mess = 'No bindings left once instances of binding-to-self have been removed';
    end
    
elseif iscell(bnd)
    if isscalar(bnd) && iscell(bnd{1}) && all(cellfun(@iscell,bnd{1}(:)))
        % Could be one of {{b1}} or {{b1,b2,...}} (but not b1, {b1} or {b1,b2,...}),
        % so strip off outer {...}
        bnd_tmp = bnd{1};
    elseif ~all(cellfun(@iscell,bnd(:)))
        % Not everything is in the cell array is a cell array (including the case
        % that nothing is a cell array i.e. is b1), so treat as a single binding
        % descriptor
        bnd_tmp = {bnd};
    else
        % Just transfer a pointer
        bnd_tmp = bnd;
    end
    % At this point, we have a cell array of cell arrays
    % Parse first descriptor
    [ok,mess,ipb,ifunb,ipf,ifunf,R,self_rem] = bind_parse_single...
        (np,nbp,isfore,ifunb_def,bnd_tmp{1});
    % Parse following descriptors
    if ok && numel(bnd_tmp)>1
        nel = numel(ipf);
        for i=2:numel(bnd_tmp)
            [ok,mess,ipb_add,ifunb_add,ipf_add,ifunf_add,R_add,self_rem_add] = bind_parse_single...
                (np,nbp,isfore,ifunb_def,bnd_tmp{i});
            if ok
                [ipb,ifunb,ipf,ifunf,R,nel] = accumulate_arrays (ipb,ifunb,ipf,ifunf,R,nel,...
                    ipb_add,ifunb_add,ipf_add,ifunf_add,R_add);
                self_rem = (self_rem && self_rem_add);
            else
                [ipb,ifunb,ipf,ifunf,R]=empty_return;
                break
            end
        end
        ipb = ipb(1:nel);
        ifunb = ifunb(1:nel);
        ipf = ipf(1:nel);
        ifunf = ifunf(1:nel);
        R = R(1:nel);
    end
else
    % Cannot be a valid format
    ok=false;
    mess='Invalid format for binding descriptor(s)';
    [ipb,ifunb,ipf,ifunf,R]=empty_return;   % just use to fill with suitable values
end

% Warning message if all bindings are trivial self-bindings
if ok && numel(ipf)==0 && self_rem
    mess = 'No bindings left once instances of binding-to-self have been removed';
end


%------------------------------------------------------------------------------
function [ipb,ifunb,ipf,ifunf,R,nel] = accumulate_arrays (ipb,ifunb,ipf,ifunf,R,nel,...
    ipb_add,ifunb_add,ipf_add,ifunf_add,R_add)
% Accumulate arrays, expanding as necessary

nel_max = numel(ipb);
n_add = numel(ipb_add);
if nel+n_add > nel_max
    % Make large enough to hold additional elements, making at least double length
    zeros_add = zeros(max(n_add,nel_max),1);
    ipb   = [ipb;   zeros_add];
    ifunb = [ifunb; zeros_add];
    ipf   = [ipf;   zeros_add];
    ifunf = [ifunf; zeros_add];
    R     = [R;     zeros_add];
end

ipb(nel+1:nel+n_add)   = ipb_add;
ifunb(nel+1:nel+n_add) = ifunb_add;
ipf(nel+1:nel+n_add)   = ipf_add;
ifunf(nel+1:nel+n_add) = ifunf_add;
R(nel+1:nel+n_add)     = R_add;

nel = nel + n_add;

%------------------------------------------------------------------------------
function [ok,mess,ipb,ifunb,ipf,ifunf,R,self_rem] = bind_parse_single(np,nbp,isfore,ifunb_def,bnd)
% Determine if a binding descriptor is valid
%
%   >> [ok,mess,ipf,ifunf,ipb,ifunb,R] = bind_parse_single(np,nbp,isfore,ifun_def,bnd)
%
% Input:
% ------
%   np          Number of parameters for each foreground function (row vector)
%   nbp         Number of parameters for each background function (row vector)
%   isfore      True if positive function index refers to foreground functions
%               False if positive function index refers to background functions
%   ifunb_def   Default function index for parameter to be bound. Reference
%              as foreground or background is determined by the value of isfore.
%                   Foreground function: in range 1 to numel(np)
%                   Background function: in range 1 to numel(nbp)
%               If there is no default set ifunb_def = []
%               If an array of default function indicies is given, then the
%              binding descrptor is evaluated for each index if the default is
%              used.
%
%   bnd         Cell array containing binding descriptor: valid forms are:
%                 If ifunb_def is given:
%                   {ipb,  ipf}
%                   {ipb, [ipf,ifun]}
%                 If ifunb_def is not given:
%                   {[ipb,ifunb],  ipf}             % assumes ifun is ifunb
%                   {[ipb,ifunb], [ipf,ifun]}
%               and with any of the above:
%                   {..., R}
%               The sign of functions is interpreted by the value of isfore.
%
% Output:
% -------
%   ok          True if binding descriptor is valid
%   mess        Error message if not ok; empty string if ok
%   ipb         Parameter index within the function, for the bound parameter
%   ifunb       Function index for the bound parameter:
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   ipf         Parameter index within the function, for the floating parameter
%   ifunf       Function index for the floating parameter:
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   self_rem    Self bindings had to be removed


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


self_rem = false;

narg = numel(bnd);

if narg==2
    R = NaN;
    
elseif narg==3
    if isscalar(bnd{3}) && isnumeric(bnd{3}) && ~isinf(bnd{3})   % finite or NaN
        R = bnd{3};
    elseif isempty(bnd{3})
        R = NaN;
    else
        ok = false;
        mess = 'Binding ratio must be a finite number or NaN';
        [ipb,ifunb,ipf,ifunf,R]=empty_return;
        return
    end
    
else
    ok = false;
    mess = 'Check format of binding descriptor';
    [ipb,ifunb,ipf,ifunf,R]=empty_return;
    return
end

% Resolve bound parameter(s)
if isfore
    [ok, mess, ipb, ifunb] = param_parse(bnd{1},np,nbp,ifunb_def,true);
else
    [ok, mess, ipb, ifunb] = param_parse(bnd{1},nbp,np,ifunb_def,true);
end
if ~ok
    mess = ['Bound parameter: ',mess];
    [ipb,ifunb,ipf,ifunf,R]=empty_return;
    return
end

% Resolve floating parameter(s)
if isfore
    [ok, mess, ipf, ifunf] = param_parse(bnd{2},np,nbp,ifunb',false);
else
    [ok, mess, ipf, ifunf] = param_parse(bnd{2},nbp,np,ifunb',false);
end
if ~ok
    mess = ['Floating parameter: ',mess];
    [ipb,ifunb,ipf,ifunf,R]=empty_return;
    return
end
if numel(ipb)>1 && numel(ipf)==1
    ipf = repmat(ipf,size(ipb));
    ifunf = repmat(ifunf,size(ifunb));
elseif ~(numel(ipb)==numel(ipb))
    error('Logic error. Contact developers')
end

% Remove any self-binding
ok_bound = ~(ipf==ipb & ifunf==ifunb);
if ~all(ok_bound)
    self_rem = true;
    ipb = ipb(ok_bound);
    ifunb = ifunb(ok_bound);
    ipf = ipf(ok_bound);
    ifunf = ifunf(ok_bound);
end
R = repmat(R,size(ipb));

% Return function index as -ve for background functions
if ~isfore
    ifunf = -ifunf;
    ifunb = -ifunb;
end


%------------------------------------------------------------------------------
function [ok, mess, ip, ifun] = param_parse(arg,np,nbp,ifun_def,bound_par)
% Parse [ip,ifun] block. If bound_par is true, then if ifun is given it is
% required to be in the array of default ifun_def (bound_par is ignored if
% ifun_def is not given). This is because we expect that a binding description
% should only refer to the functions that are in the default list.
%
%   [ip]        % use ifun_def
%   [ip,ifun]   % if bound_par==true, then must have ifun in the array ifun_def
%   [-ip]       % changes sign of ifun_def
%
% Negative parameter index is only allowed if the function index has been
% taken from the default.
%
%   np          Number of parameters for each foreground function (row vector)
%   nbp         Number of parameters for each background function (row vector)
%   ifun_def    Default function index or array of indicies (row vector)
%               It is assumed hat all elements are in the range 1 - numel(np)
%   bound_par   True if parsing the bound parameters, false if parsing the
%               floating parameters.


% Check format of parameter-function pair
n = numrowvec (arg);
ip_was_negative = false;
if n==2
    if ~isempty(ifun_def) && bound_par
        if any(arg(2)==ifun_def)    % implicitly enforces ifun >=1 for bound_par==true
            ip = arg(1);
            ifun = arg(2);
        else
            mess = 'Function index does not match required value';
            ok=false; ip = 0; ifun = 0;
            return
        end
    else
        ip = arg(1);
        ifun = arg(2);
    end
elseif n==1
    if ~isempty(ifun_def)
        ip = arg;
        ifun = ifun_def;
        if ip<=-1
            if bound_par
                mess = 'Cannot have negative parameter index for the bound parameter';
                ok=false; ip = 0; ifun = 0;
                return
            else
                ip = -ip;
                if numel(nbp)==1
                    ifun = -ones(size(ifun));
                else
                    ifun = -ifun;
                end
                ip_was_negative = true;
            end
        end
    else
        mess = 'Function index must be given';
        ok=false; ip = 0; ifun = 0;
        return
    end
else
    mess='Invalid format of a binding descriptor';
    ok=false; ip = 0; ifun = 0;
    return
end

% Check validity
if ip<1
    if ip_was_negative
        mess = 'Parameter index cannot be zero';
    else
        mess = 'Parameter index must be >= 1';
    end
    ok=false; ip = 0; ifun = 0;
    return
end

nnp = numel(np);
nnbp = numel(nbp);
if bound_par
    % Bound parameter parsing. All functions must be positive
    if any(ifun<1 | ifun>nnp)
        mess = ['Invalid function index (must be in range 1 to ',num2str(nnp)];
        ok=false; ip = 0; ifun = 0;
        return
    end
else
    % All function indicies will have the same sign by construction
    if any(ifun==0 | ifun<-nnbp | ifun>nnp)
        if ip_was_negative  % will have all function indicies -ve now
            mess = ['Invalid function index (must be in range 1 to ',num2str(nnbp),')'];
        else
            mess = ['Invalid function index (must be in range ',num2str(-nnbp),' to -1, 1 to ',num2str(nnp),')'];
        end
        ok=false; ip = 0; ifun = 0;
        return
    end
end

ifun_pos = (ifun>0);
ipmax = min([np(ifun(ifun_pos)),nbp(abs(ifun(~ifun_pos)))]);
if ip<=ipmax
    mess = '';
    ok = true;
    if numel(ifun)>1
        ifun = ifun(:);                 % make column
        ip = repmat(ip,size(ifun));     % also a column
    end
else
    mess = ['Parameter index ',num2str(ip),' exceeds maximum possible value of ',num2str(ipmax)];
    ok=false; ip = 0; ifun = 0;
end

%------------------------------------------------------------------------------
function n = numrowvec (arg)
% Check if an argument is row vector of integers
if isnumeric(arg) && isrowvector(arg) && all(rem(arg,1)==0)
    n = numel(arg);
else
    n = -1;
end

%------------------------------------------------------------------------------
function [ok,mess,ipb,ifunb,ipf,ifunf,R,self_rem] = bind_parse_array (np,nbp,isfore,bnd)
% Determine if a binding array is valid
%
%   >> [ok,mess,ipb,ifunb,ipf,ifunf,R] = bind_parse_array (np,nbp,isfore,bnd)
%
% Input:
% ------
%   np          Number of parameters for each foreground function (row vector)
%   nbp         Number of parameters for each background function (row vector)
%   isfore      True if positive function index refers to foreground functions
%               False if positive function index refers to background functions
%
%   bnd         Array of bindings, size [nbnd,5], where the columns are
%                   [ipb, ifunb, ipf, ifunf, R]
%              as given below, except that if isfore==true the signs of functions
%              are positive for foreground functions, negative for background
%              functions; if isfore==false, then the other way round
%
% Output:
% -------
%   ok          True if binding descriptor is valid
%   mess        Error message if not ok; empty string or warning/informational
%              message if ok
%   ipb         Parameter indicies within the functions for the bound parameters
%              (column vector))
%   ifunb       Function indicies for the bound parameterd (column vector):
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   ipf         Parameter indicies within the functions for the floating parameters
%   ifunf       Function index for the floating parameter(column vector):
%              (column vector))
%                   foreground functions: numbered 1,2,3,...numel(np)
%                   background functions: numbered -1,-2,-3,...-numel(nbp)
%   R           Ratio of values of bound/independent parameters (column vector).
%               If to be set by values of initial parameter values, then is NaN;
%              otherwise is finite.
%   self_rem    Self bindings had to be removed


self_rem = false;

if ~isnumeric(bnd) || numel(size(bnd))~=2 || size(bnd,2)~=5
    mess = 'Numeric binding array must be an n x 5 array';
    ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    
elseif size(bnd,1)==0
    mess = '';
    ok = true; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    
else
    ipb   = bnd(:,1);
    ifunb = bnd(:,2);
    if ~isfore, ifunb = -ifunb; end
    ipf   = bnd(:,3);
    ifunf = bnd(:,4);
    if ~isfore, ifunf = -ifunf; end
    R     = bnd(:,5);
    
    % Check validity of contents
    % --------------------------
    % Check binding ratios
    if any(isinf(R))
        mess = 'One or more binding ratios is infinite';
        ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    end
    
    % Check function indicies are in range
    nf=numel(np);
    nbf=numel(nbp);
    if any(ifunb==0 | ifunb<-nbf | ifunb>nf)
        mess = 'One or more bound function indicies are outside the range set by the number foregrond and background functions';
        ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    end
    if any(ifunf==0| ifunf<-nbf | ifunf>nf)
        mess = 'One or more floating function indicies are outside the range set by the number foregrond and background functions';
        ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    end
    
    % Check the parameter indicies are in range
    ipbmax=zeros(size(ipb));
    ix=(ifunb>0); ipbmax(ix)=np(ifunb(ix));
    ix=(ifunb<0); ipbmax(ix)=nbp(abs(ifunb(ix)));
    if any(ipb<=0 | ipb>ipbmax)
        mess = 'One or more bound parameter indicies are outside the range set by the number of parameters for the corresponding function';
        ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    end
    ipfmax=zeros(size(ipf));
    ix=(ifunf>0); ipfmax(ix)=np(ifunf(ix));
    ix=(ifunf<0); ipfmax(ix)=nbp(abs(ifunf(ix)));
    if any(ipf<=0 | ipf>ipfmax)
        mess = 'One or more floating parameter indicies are outside the range set by the number of parameters for the corresponding function';
        ok = false; [ipb,ifunb,ipf,ifunf,R]=empty_return; return
    end
    
    % Remove any self bindings
    ok_bound = ~(ipf==ipb & ifunf==ifunb);
    if ~all(ok_bound)
        self_rem = true;
        ipb = ipb(ok_bound);
        ifunb = ifunb(ok_bound);
        ipf = ipf(ok_bound);
        ifunf = ifunf(ok_bound);
        R = R(ok_bound);
    end
    
    % All is OK if got to here
    ok=true; mess='';
end

%------------------------------------------------------------------------------
function [ipb,ifunb,ipf,ifunf,R]=empty_return
% Return values on error
ipb = zeros(0,1);
ifunb = zeros(0,1);
ipf = zeros(0,1);
ifunf = zeros(0,1);
R = zeros(0,1);
