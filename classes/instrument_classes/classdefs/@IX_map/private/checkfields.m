function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid object, empty string if is valid.
%   wout    Output structure or object of the class
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to
%     isvalid.m and the consequent call to checkfields.m ...
%
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)

% Original author: T.G.Perring
%
%   ns      Row vector of number of spectra in erach workspace. There must be
%          at least one workspace. ns(i)=0 is permitted (it means no spectra in ith workspace)
%   s       Row vector of spectrum indicies in workspaces concatenated together.The
%          spectrum numbers are sorted into numerically increasing order for
%          each workspace
%   wkno    Workspace numbers (think of them as the 'names' of the workspaces).
%          Must be unique, and greater than or equal to one.
%           If [], this means leave undefined.

fields = {'ns';'s';'wkno'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    % Check ns
    if ~isrowvector(wout.ns)
        wout.ns=wout.ns(:)';  % make a row vector
    end
    if ~isnumeric(wout.ns) || any(rem(wout.ns,1)~=0) || min(wout.ns)<0
        message='The number of spectra in each workspace must all be integers greater than or equal to zero';
        return
    else
        nw=numel(wout.ns);
        if nw<1
            message='There must be at least one workspace in the map';
            return
        end
    end
    
    % Check s
    if ~isrowvector(wout.s)
        wout.s=wout.s(:)';   % make a row vector
    end
    if ~isnumeric(wout.s) || any(rem(wout.s,1)~=0) || (numel(wout.s)>0 && min(wout.s)<1)    % must allow for wout.s being empty
        message='The spectrum indicies must all be integers greater than or equal to one';
        return
    else
        if sum(wout.ns)~=numel(wout.s)
            message='The number of spectra in each workspace and the length of the list of spectrum indicies are inconsistent';
            return
        end
        if numel(wout.s)~=numel(unique(wout.s))
            message='A spectrum in a spectrum-to-workspace map can only appear once';
            return
        end
    end
    
    % Check wkno
    if ~isempty(wout.wkno)
        if ~isrowvector(wout.wkno)
            wout.wkno=wout.wkno(:)';  % make a row vector
        end
        if ~isnumeric(wout.wkno) || any(rem(wout.wkno,1)~=0) || min(wout.wkno)<1
            message='The workspace indicies (i.e. spectrum group indicies) must all be integers greater than or equal to one';
            return
        else
            if numel(wout.wkno)~=numel(wout.ns)
                message='The number of workspaces indicies does not match the number of workspaces';
                return
            end
            if numel(wout.wkno)~=numel(unique(wout.wkno))
                message='The workspace indicies must all be unique';
                return
            end
        end
    else
        wout.wkno=zeros(1,0);
    end
    
    % Sort spectra
    do_sort=find(wout.ns>1);    % those spectra that need sorting
    if any(do_sort)
        nend=cumsum(wout.ns);
        nbeg=nend-wout.ns+1;
        s=wout.s;
        for i=do_sort
            s(nbeg(i):nend(i))=sort(s(nbeg(i):nend(i)));
        end
        wout.s=s;
    end
    
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
