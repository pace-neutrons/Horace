function [ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse(pbind,isforeground,np,nbp)
% Resolve a binding description
%
%   >> [ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse(pbind,isforeground,np,nbp)
%
% Input:
% ------
%   pbind       Binding descriptions for either the foreground or background functions.
%              The type of function being considered is given by the value of the
%              input argument foreground defined below.
%
%               If there is only one function of the given type, that is, the
%              function applies globally to all datasets, then pbind must be a
%              valid function binding descriptor:
%                - An empty argument (which means no binding) e.g. {} or []
%                - A single parameter binding descriptor      e.g. {1,3} or {2,5,[7,2]}
%                - A cell array of parameter binding descriptors  e.g. {{1,3},{2,5,[7,2]}}
%               Equivalently:
%                - A cell array containing one of the above forms
%
%               If there is more than one function the functions apply locally,
%              one per dataset, and pbind must be:
%                - An empty argument (which means no binding for all of the functions)
%                - A cell array of valid function binding descriptions, one per
%                 function
%                - A cell array containing a single valid function binding
%                 description; this will be repeated for each function
%
%
%   isforeground  Logical flag
%                - true  if binding descrption is for foreground function(s)
%                - false if binding descrption is for background function(s)
%
%   np          Number of parameters in foreground functions
%               (array with same size as foreground functions array)
%
%   nbp         Number of parameters in background functions
%               (array with same size as background functions array)
%
% Output:
% -------
%   ok          =true if valid, =false if not
%   mess        Error message if not OK; is '' if OK
%
%   ipbound     Cell array of column vectors of indicies of bound parameters,
%              one vector per function
%              (Cell array has the same size as the corresponding functions array)
%
%   ipboundto   Cell array of column vectors of the parameters to which those
%              parameters are bound, one vector per function
%              (Cell array has the same size as the corresponding functions array)
%
%   ifuncboundto  Cell array of column vectors of single indicies of the functions
%              corresponding to the free parameters, one vector per function. The
%              index is ifuncboundto(i)<0 for foreground functions, and >0 for
%              background functions.
%              (Cell array has the same size as the corresponding functions array)
%
%   pratio      Cell array of column vectors of the ratios (bound_parameter/free_parameter),
%              if the ratio was explicitly given. Will contain NaN if not (the
%              ratio will be determined from the initial parameter values). One
%              vector per function.
%              (Cell array has the same size as the corresponding functions array)
%
%   If not OK, then the four last output cell arrays are set to:
%       ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
%
%   Apart from syntax check and simple checks that parameter and function indicies
%  lie in the permitted ranges, only the simplest consistency checks are performed:
%   - a parameter is only be bound once
%   - a parameter is not bound to another bound parameter within the same function
%   In particular, chains of binding across functions are not checked. This has
%  to be done by another function.
%
%
%  Form of function binding description
%  ------------------------------------
%  The general form of a function binding description is a cell array of
% parameter binding descriptors.
%
%  In turn, a parameter binding descriptor is a cell arrays with the general
% form:
%     {<parameter to bind>, <parameter to bind to>, <function index>, <ratio>}
%
%  Only the first two of these need to be given; defaults are chosen for the
% other two. Some examples should make it clearer:
%
% EXAMPLES:
%       Bind using ratio of the initial parameter values:
%           {1,3}           Bind parameter 1 to parameter 3 of the same function
%           {1,3,13}        Bind p1 to p3 of background function 13
%           {1,3,-5}        Bind p1 to p3 of foreground function 5
%           {1,3,[7,3,2]}   Bind p1 to p3 of background function index [7,3,2]
%           {1,3,-[4,2]}    Bind p1 to p3 of foreground function index [4,2]
%          {1,3,-[4,2],NaN} Equivalent to the above (NaN means 'use the initial ratio')
%
%          If only one foreground function, then index 0 will refer to this
%           {1,3,0}         Bind p1 to p3 of the sole foreground function
%
%       Explicitly give the ratio
%           {1,3,[],7.2}    Bind p1 to p3 of same function, with ratio p1/p3=7.2
%           {1,3,13,7.2}    Bind p1 to p3 of background function 13, ratio p1/p3=7.2
%           {1,3,[7,3,2],7.2}
%           {1,3,-5,7.2}    Bind p1 to p3 of foreground function 5, ratio p1/p3=7.2
%           {1,3,-[4,2],7.2}
%
%         If only one foreground function, then index 0 will refer to this
%           {1,3,0,7.2}     Bind p1 to p3 of the sole foreground function, ratio p1/p3=7.2
%
%    where:
%         <param. to bind> = Index of the parameter of a function that is
%                             going to be bound to another parameter
%
%
%  Parameter descriptors are combined to make a function binding description
% for example;
%     {1,2}
%    {{1,2}, {3,5}, {4,5}}
%    {{1,2}, {3,4,[4,7],5.2}, {4,5,-12}}
%
%
%  EXAMPLES of pbind:
%  ------------------
%   If a single foreground function: np=3; nbp=[2,4]; foreground=true
%     {1,2}
%     {1,4}         % INVALID: there are only 3 parameters in foreground function
%     {1,2,[],7.2}  % Fix ratio of parameters 1 and 2 to 7.2
%    {{1,2}, {3,4,2,5.2}}   % Bind p1 & p2; bind p3 to p4 of 2nd background in ratio 5.2
%
%   If a single foreground function: np=3; nbp=[5,4]; foreground=false
%     ''            % No binding
%     {1,2}         % INVALID: must have a call array with a single valid function
%                   % Binding description if want to have it apply to all backgrounds
%    {{1,2}}        % Correct syntax to bind p1 to p2 for each of the two backgrounds
%    {{1,2}, {1,2}} % Equivalent syntax
%    {{1,2}, {2,4}} % Different bindings for the two functions
%    {{{1,2},{3,4}}}% Bind p1 to p2 and p3 to p4, for each of the two functions
%    {{1,2,-1,0.42}, {4,2,1}}   % Bind p1 of first background function to p2 of foreground
%                               % function with ratio 0.42, and p4 of second background to
%                               % p2 of the first background in the ratio of the initial
%                               % parameter values
%    {{{1,2},{5,1,-1,0.25}}, {{2,4},{3,1,1}}} % Different bindings for the two functions
%
%   If np=[6,5;3,3]; nbp=[5,4]; foreground=true
%    {{{1,2},{5,3,-[2,2],0.25}}, {{2,4},{3,1,1}}; {}, {{2,5,1},{3,4,2}}}

% Set parameters according to foreground or background functions being considered
if isforeground
    func_type_str='Foreground function';
    sz=size(np);
    sgn=-1;
else
    func_type_str='Background function';
    sz=size(nbp);
    sgn=1;
end

% Parse the binding description
if prod(sz)==1
    % Single function
    ipbound=cell(sz); ipboundto=cell(sz); ifuncboundto=cell(sz); pratio=cell(sz);
    if iscell(pbind) && isscalar(pbind)
        % Case of {binding_descriptor} (there is no valid pbind such that {pbind} is also valid)
        pbind=pbind{1};
    end
    [ok,mess,ipbound{1},ipboundto{1},ifuncboundto{1},pratio{1}]=pbind_parse_single(pbind,np,nbp,sgn);
    if ~ok
        mess=[func_type_str,' ',arraystr(sz,1),': ',mess];
        ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
        return
    end
else
    % Multiple functions
    if iscell(pbind) && ~isempty(pbind)
        if isscalar(pbind)  % the binding argument is assumed to apply for every function; must test validity for each function of course
            ipbound=cell(sz); ipboundto=cell(sz); ifuncboundto=cell(sz); pratio=cell(sz);
            for i=1:prod(sz)
                [ok,mess,ipbound{i},ipboundto{i},ifuncboundto{i},pratio{i}]=pbind_parse_single(pbind{1},np,nbp,i*sgn);
                if ~ok
                    mess=[func_type_str,' ',arraystr(sz,i),': ',mess];
                    ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
                    return
                end
            end
            ok=true;
            mess='';
        elseif numel(pbind)==prod(sz)
            ipbound=cell(sz); ipboundto=cell(sz); ifuncboundto=cell(sz); pratio=cell(sz);
            for i=1:prod(sz)
                [ok,mess,ipbound{i},ipboundto{i},ifuncboundto{i},pratio{i}]=pbind_parse_single(pbind{i},np,nbp,i*sgn);
                if ~ok
                    mess=[func_type_str,' ',arraystr(sz,i),': ',mess];
                    ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
                    return
                end
            end
            ok=true;
            mess='';
        else
            ok=false;
            mess=[func_type_str,'(s): Bound parameters list is not scalar or does not have same size as array of data sources'];
            ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
            return
        end
        
    elseif isempty(pbind)   % Empty argument; assume no binding
        ipbound=cell(sz); ipboundto=cell(sz); ifuncboundto=cell(sz); pratio=cell(sz);
        for i=1:prod(sz)
            [ok,mess,ipbound{i},ipboundto{i},ifuncboundto{i}]=pbind_parse_single({},np,nbp,i*sgn);     % will have OK==true
        end
        ok=true;
        mess='';
        
    else
        ok=false;
        mess=[func_type_str,'(s): Bound parameters list must be empty or a cell array'];
        ipbound={}; ipboundto={}; ifuncboundto={}; pratio={};
        return
    end
end

%----------------------------------------------------------------------------------------------------------------------
function [ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse_single(pbind,np,nbp,ind)
% Resolve the binding description for one function
%
%   >> [ok,mess,ipbound,ipboundto,ifuncboundto,pratio]=pbind_parse_single(pbind_in,np,nbp,ind)
%
% Input:
% ------
%   pbind   Binding description:
%             - Empty argument (which means no binding) e.g. {} or []
%             - A single parameter binding descriptor   e.g. {1,3} or {2,5,[7,2]}
%             - Cell array of parameter binding descriptors  e.g. {{1,3},{2,5,[7,2]}}
%
%           In detail, a parameter binding descriptor has one of the following forms:
%
%           No binding: any empty argument:
%               {}
%               ''
%               []
%
%           Bind using ratio of the initial parameter values:
%               {1,3}           Bind parameter 1 to parameter 3 of the same function
%               {1,3,13}        Bind p1 to p3 of background function 13
%               {1,3,-5}        Bind p1 to p3 of foreground function 5
%               {1,3,[7,3,2]}   Bind p1 to p3 of background function index [7,3,2]
%               {1,3,-[4,2]}    Bind p1 to p3 of foreground function index [4,2]
%              {1,3,-[4,2],NaN} Equivalent to the above (NaN means 'use the initial ratio')
%
%              If only one foreground function, then index 0 will refer to this
%               {1,3,0}         Bind p1 to p3 of the sole foreground function
%
%           Explicitly give the ratio
%               {1,3,[],7.2}    Bind p1 to p3 of same function, with ratio p1/p3=7.2
%               {1,3,13,7.2}    Bind p1 to p3 of background function 13, ratio p1/p3=7.2
%               {1,3,[7,3,2],7.2}
%               {1,3,-5,7.2}    Bind p1 to p3 of foreground function 5, ratio p1/p3=7.2
%               {1,3,-[4,2],7.2}
%
%              If only one foreground function, then index 0 will refer to this
%               {1,3,0,7.2}     Bind p1 to p3 of the sole foreground function, ratio p1/p3=7.2
%
%   np      Number of parameters in foreground functions
%          (array with same size as foreground functions array)
%
%   nbp     Number of parameters in background functions
%          (array with same size as background functions array)
%
%   ind     Scalar index of function handle array for which the validity of the binding
%          description is being tested (the value of ind is assumed to be valid)
%               ind>0   basckground function
%               ind<0   foreground function
%
%
% Output:
% -------
%   ok          =true if valid, =false if not
%   mess        Error message if not OK; is '' if OK
%   ipbound     Column vector of indicies of bound parameters:
%                   - if foreground function (ind<0): in the range 1->np(abs(ind))
%                   - if background function (ind>0): in the range 1->nbp(ind)
%   ipboundto   Column vector of the parameters to which those parameters are bound.
%               If the ith parameter is bound to
%                   - a foreground function, ipboundto(i) is in the range 1->np(abs(ifuncboundto(i)))
%                   - a background function, ipboundto(i) is in the range 1->nbp(ifuncboundto(i))
%   ifuncboundto  Column vector of single indicies of the functions corresponding to the free parameters
%   pratio      Column vector of the ratios (bound_parameter/free_parameter),
%              if the ratio was explicitly given. Will contain NaN if not (the
%              ratio will be determined from the initial parameter values)


if isempty(pbind)    % No binding
    ok=true;
    mess='';
    ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
    
elseif iscell(pbind) % A single binding descriptor, or a cell array of binding descriptors
    % Get number of parameters for the present function index
    if ind<0   % foreground function index
        npbind=np(-ind);
    elseif ind>0
        npbind=nbp(ind);
    end
    if npbind==0
        ok=false;
        mess='There are no parameters for the function in binding description';
        ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
        return
    end
    
    % Every element of pbind must be a cell array, or it is assumed that pbind is a single descriptor
    for i=1:numel(pbind)
        if ~iscell(pbind{i})
            pbind={pbind};
            break
        end
    end
    
    % Now have a non-empty cell array of cell arrays. Need to check if the individual cell arrays are valid binding entries
    ipbound=zeros(numel(pbind),1);
    ipboundto=zeros(numel(pbind),1);
    ifuncboundto=zeros(numel(pbind),1);
    pratio=zeros(numel(pbind),1);
    for i=1:numel(pbind)
        % Ensure that there are 2,3 or 4 elements in the binding description
        if numel(pbind{i})<2 || numel(pbind{i})>4
            ok=false;
            mess=['Invalid number of parameters in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        
        % Check first two elements are numeric scalars - these are the bound and bound-to parameters
        if ~(isscalar(pbind{i}{1}) && all_positive_integers(pbind{i}{1})) ||...
                ~(isscalar(pbind{i}{2}) && all_positive_integers(pbind{i}{2}))
            ok=false;
            mess=['Binding parameters must be positive integers in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        ipbound(i)=pbind{i}{1};
        ipboundto(i)=pbind{i}{2};
        
        % Find the function to which the bound-to parameter belongs
        if numel(pbind{i})==2   % Bound within the same function with unspecified ratio
            npfree=npbind;
            ifuncboundto(i)=ind;
            pratio(i)=NaN;
            
        elseif numel(pbind{i})>=3 && isnumeric(pbind{i}{3}) && (isempty(pbind{i}{3})||isrowvector(pbind{i}{3}))    % Bound to a specified function
            if isempty(pbind{i}{3})     % bound within the same function
                npfree=npbind;
                ifuncboundto(i)=ind;
            elseif isscalar(pbind{i}{3}) && pbind{i}{3}==0  % bound to global foreground, if there is one
                if numel(np)==1
                    npfree=np;
                    ifuncboundto(i)=-1;
                else
                    ok=false;
                    mess=['Function index 0 invalid unless global foreground function, in binding description ',num2str(i)];
                    ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                    return
                end
            else    % bound to specified function
                if all_negative_integers(pbind{i}{3})
                    tmp=num2cell(-pbind{i}{3});
                    try
                        npfree=np(tmp{:});     % test if a valid index
                        ifuncboundto(i)=-sub2ind(size(np),tmp{:});
                    catch
                        ok=false;
                        mess=['Invalid index to foreground function in binding description ',num2str(i)];
                        ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                        return
                    end
                    
                elseif all_positive_integers(pbind{i}{3})
                    tmp=num2cell(pbind{i}{3});
                    try
                        npfree=nbp(tmp{:});     % test if a valid index
                        ifuncboundto(i)=sub2ind(size(nbp),tmp{:});
                    catch
                        ok=false;
                        mess=['Invalid index to background function in binding description ',num2str(i)];
                        ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                        return
                    end
                else
                    ok=false;
                    mess=['Invalid index to foreground or background function in binding description ',num2str(i)];
                    ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                    return
                end
            end
            
            % Get binding ratio, if given
            if numel(pbind{i})==4
                if isnumeric(pbind{i}{4}) && isscalar(pbind{i}{4})
                    pratio(i)=pbind{i}{4};
                    if isinf(pbind{i}{4})   % we accept NaN as meaning the ratio will be defined by initial parameter values
                        ok=false;
                        mess=['Parameter binding ratio must be finite in binding description ',num2str(i)];
                        ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                        return
                    end
                else
                    ok=false;
                    mess=['Parameter binding ratio is not a numeric scalar in binding description ',num2str(i)];
                    ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
                    return
                end
            else
                pratio(i)=NaN;
            end
        else
            ok=false;
            mess=['Syntax is invalid in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        
        % Check there are parameters for the bound-to function
        if npfree==0
            ok=false;
            mess=['There are no parameters for the function to which a parameter is bound in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        
        % Check that the bound and free parameter indicies lie in valid ranges (1-> no. parameters for the functions)
        if ~(ipbound(i)>0 && ipbound(i)<=npbind)
            ok=false;
            mess=['Bound parameter index not in range 1-',num2str(npbind),' in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        elseif ~(ipboundto(i)>0 && ipboundto(i)<=npfree)
            ok=false;
            mess=['Free parameter index not in range 1-',num2str(npfree),' in binding description ',num2str(i)];
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        
    end
    % Perform various tests that the binding is consistent
    if numel(pbind)>0
        % Test if a parameter is bound to itself
        if any((ipbound==ipboundto)&(ifuncboundto==ind))
            ok=false;
            mess='At least one parameter is bound to itself';
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        % Test if a parameter is bound more than once
        if any(diff(sort(ipbound))==0)
            ok=false;
            mess='One or more parameters are bound at least twice';
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
        % Test that bound parameters for the given function do not appear in the bound-to parameter list
        bound=false(1,npbind); bound(ipbound)=true;
        boundto=false(1,npbind); boundto(ipboundto(ifuncboundto==ind))=true;
        if any(bound&boundto)
            ok=false;
            mess='One or more parameters are bound to a parameter in the same function that is also set to be bound';
            ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
            return
        end
    end
    % All OK if got this far
    ok=true;
    mess='';
    
else
    ok=false;
    mess='Parameter binding argument does not have correct syntax';
    ipbound=zeros(0,1); ipboundto=zeros(0,1); ifuncboundto=zeros(0,1); pratio=zeros(0,1);
    return
end

%----------------------------------------------------------------------------------------------------------------------
function ok=all_positive_integers(n)
% Determine if all the elements of an array are integers greater than zero
if isnumeric(n) && all(mod(n(:),1)==0) && all(n(:)>0)
    ok=true;
else
    ok=false;
end

%----------------------------------------------------------------------------------------------------------------------
function ok=all_negative_integers(n)
% Determine if all the elements of an array are integers less than zero
if isnumeric(n) && all(mod(n(:),1)==0) && all(n(:)<0)
    ok=true;
else
    ok=false;
end
