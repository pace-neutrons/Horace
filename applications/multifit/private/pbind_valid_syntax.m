function [ok,mess,ipbind,ipfree,ifuncbind,rpbind]=pbind_valid_syntax(pbind_in,np,nbp,ind)
% Determine if an argument has syntax to be a valid binding description for a function
%
%   >> [ok,mess,ipbind,ipfree,ifuncbind,rpbind]=pbind_valid_syntax(pbind_in,np,nbp,ind)
%
% Input:
% ------
%   pbind   Binding description
%           Binding description element can be:
%               {}              empty cell array
%               {1,3}           cell array with 2 scalars
%           In the following, the ratio is assumed to be that of the initial parameter values
%               {1,3,0}
%               {1,3,13}        
%               {1,3,[7,3,2]}   cell array with 2 scalars and a vector
%           Explicitly give the ratio
%               {1,3,0,7.2}
%               {1,3,13,7.2}       
%               {1,3,[7,3,2],7.2}
% 
%           Full binding description can be a cell array of such objects
%
%   np      Number of parameters in global function
%   nbp     Number of parameters in background functions
%           Note: size(nbp)=size of array of data objects
%   ind     Single index into the background function handle array (ind>0) for which
%           the validity of the binding description is being tested. To test a 
%           description for the global function, set ind=0.
%
% Output:
% -------
%   ok      =true if valid, =false if not
%   mess    Error message if ~OK; is '' if OK
%   ipbind  Column vector of indicies of bound parameter in the range 1->nbp(ind) (1->np if ind==0)
%   ipfree  Column vector of the parameters to which those parameters are bound, in the
%           range 1->np(ifuncbind(i)) for each element i of the array.
%   ifuncbind Column vector of single indicies of the functions corresponding to the free parameters
%   rpbind  Column vector of the ratios bound_parameter/free_parameter, if given. Will contain NaN if not.

ok=false;
ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);

     
% Check syntax and validity of binding descriptions
if iscell(pbind_in)
    % Get number of parameters for the present function index
    if ind==0   % global function index
        npbind=np;
    else
        npbind=nbp(ind);
    end
    if npbind==0
        ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
        mess='There are no parameters to bind for the function in binding description 1';
        return
    end
    % Check if have a valid syntax for cell array
    if ~isempty(pbind_in)
        if ~iscell(pbind_in{1})    % if valid, can only be a single binding entry
            pbind{1}=pbind_in;
        else    % if valid, must be a cell array of binding entries
            for i=1:numel(pbind_in)
                status=iscell(pbind_in{i});
                if ~status, break, end
            end
            if status
                pbind=pbind_in;     % every element is a cell array
            else
                mess='Cell array of binding descriptions does not have correct syntax';
                return
            end
        end
    else
        pbind=pbind_in;         % empty cell array - special case means no binding
    end
    % Now have a valid cell array of binding entries. Need to check if the individual binding entries are valid
    ipbind=zeros(numel(pbind),1);
    ipfree=zeros(numel(pbind),1);
    ifuncbind=zeros(numel(pbind),1);
    rpbind=zeros(numel(pbind),1);
    for i=1:numel(pbind)
        if numel(pbind{i})>=2 && numel(pbind{i})<=4
            if (isscalar(pbind{i}{1}) && isnumeric(pbind{i}{1})) && (isscalar(pbind{i}{2}) && isnumeric(pbind{i}{2}))
                ipbind(i)=pbind{i}{1};
                ipfree(i)=pbind{i}{2};
                if numel(pbind{i})>=3 && isvector(pbind{i}{3}) && isnumeric(pbind{i}{3}) && size(pbind{i}{3},1)==1    % valid index syntax
                    if isscalar(pbind{i}{3}) && pbind{i}{3}==0
                        npfree=np;
                        ifuncbind(i)=0;   % refers to global background
                    else
                        try
                            tmp=mat2cell(pbind{i}{3},1,ones(size(pbind{i}{3})));
                            npfree=nbp(tmp{:});     % test if a valid index
                            ifuncbind(i)=sub2ind(size(nbp),tmp{:});
                        catch
                            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                            mess=['Invalid index to background function handle for binding description ',num2str(i)];
                            return
                        end
                    end
                    if numel(pbind{i})==4
                        if isnumeric(pbind{i}{4}) && isscalar(pbind{i}{4})
                            rpbind(i)=pbind{i}{4};
                            if ~isfinite(pbind{i}{4})
                                ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                                mess=['Parameter binding ratio must be finite in binding description ',num2str(i)];
                                return
                            end
                        else
                            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                            mess=['Parameter binding ratio not numeric scalar for binding description ',num2str(i)];
                            return
                        end
                    else
                        rpbind(i)=NaN;
                    end
                elseif numel(pbind{i})==2
                    npfree=npbind;
                    ifuncbind(i)=ind;       % bound within the same function
                    rpbind(i)=NaN;
                else
                    ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                    mess=['Syntax is invalid for binding description ',num2str(i)];
                    return
                end
                if npfree==0
                    ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                    mess=['There are no parameters for the function to which a parameter is bound in binding description ',num2str(i)];
                    return
                end
                if ~(ipbind(i)>0 && ipbind(i)<=npbind)
                    ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                    mess=['Bound parameter index not in range 1-',num2str(npbind),' for binding description ',num2str(i)];
                    return
                elseif ~(ipfree(i)>0 && ipfree(i)<=npfree)
                    ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                    mess=['Free parameter index not in range 1-',num2str(npfree),' for binding description ',num2str(i)];
                    return
                end
            else
                ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
                mess=['Syntax is invalid for binding description ',num2str(i)];
                return
            end
        else
            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
            mess=['Syntax is invalid for binding description ',num2str(i)];
            return
        end
    end
    % Perform various tests that the binding is OK
    if numel(pbind)>0
        % Test if a parameter is bound to itself
        if any((ipbind==ipfree)&(ifuncbind==ind))
            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
            mess='At least one parameter is bound to itself';
            return
        end
        % Test if a parameter is bound more than once
        if any(diff(sort(ipbind))==0)
            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
            mess='One or more parameters are bound at least twice';
            return
        end
        % Test that bound parameters for the given function do not appear in the free parameter list
        bound=false(1,npbind); bound(ipbind)=true;
        free=false(1,npbind); free(ipfree(ifuncbind==ind))=true;
        if any(bound&free)
            ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
            mess='One or more parameters are bound to a parameter that is also set to be bound';
            return
        end
    end
    % All OK if got this far
    ok=true;
    mess='';
    
elseif isempty(pbind_in)
    % We will allow this as a special case, as so commonly will be entered, even if not rigorously valid syntax
    ipbind=zeros(0,1); ipfree=zeros(0,1); ifuncbind=zeros(0,1); rpbind=zeros(0,1);
    ok=true;
    mess='';
    
else
    mess='Parameter binding argument does not have correct syntax';
    return
end
