function [ok, message, pout] = checkfields (p)
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


ok=true;
if isobject(p)
    pout=p;
else
    pout=default_proj();
end
message='';

tol=1e-12;

if ~all(ismember(fieldnames(p),[fieldnames(default_proj);{'lab1';'lab2';'lab3';'lab4'}]))
    message='One or more unrecognised fields passed in projection description';
    ok=false; pout=default_proj(); return
end


% Check vectors u,v and w
% -----------------------
isu=isobject(p) || isfield(p,'u'); isv=isobject(p) || isfield(p,'v'); isw=isobject(p) || isfield(p,'w');
if ~(isu || isv || isw) % none of u,v,w were given
    pout.u=[1,0,0];
    pout.v=[0,1,0];
    pout.w=[];
elseif isu && isv       % u and v both given
    if isnumeric(p.u) && numel(p.u)==3 && isnumeric(p.v) && numel(p.v)==3 && norm(p.u)>tol && norm(p.v)>tol
        % Check u and v
        if norm(cross(p.u,p.v))/(norm(p.u)*norm(p.v)) > tol
            pout.u=p.u(:)';
            pout.v=p.v(:)';
        else
            message='Vectors u and v are collinear or almost collinear';
            ok=false; pout=default_proj(); return
        end
        % Check w, if given
        if isw
            if isnumeric(p.w) && numel(p.w)==3 && norm(p.w)>tol
                if abs(det([p.u(:),p.v(:),p.w(:)]))>tol
                    pout.w=p.w(:)';
                else
                    message='Vector w is coplanar (or almost coplanar) with u and v';
                    ok=false; pout=default_proj(); return
                end
            elseif isempty(p.w)
                pout.w=[];  % must catch case of object coming in, for which p.w=[] is ok
            else
                message='If given, vector w must have three elements corresponding to (h,k,l) (not all zero)';
                ok=false; pout=default_proj(); return
            end
        else
            pout.w=[];
        end
    else
        message='Vectors u and v must have three elements corresponding to (h,k,l) (not all zero)';
        ok=false; pout=default_proj(); return
    end
    
else
    message='Must give two vectors u, v to define the projection axes';
    ok=false; pout=default_proj(); return
end


% Check orthogonality
% -------------------
if isobject(p) || isfield(p,'nonorthogonal')
    if islognumscalar(p.nonorthogonal)
        pout.nonorthogonal=logical(p.nonorthogonal);
    else
        message='Field ''nonorthogonal'' must be true or false (or 0 or 1)';
        ok=false; pout=default_proj(); return
    end
else
    pout.nonorthogonal=false;
end


% Normalisation type
% ------------------
if (isobject(p) || isfield(p,'type')) && ~isempty(p.type)
    if isstring(p.type) && numel(p.type)==3
        type=lower(p.type);
        if ~(isempty(strfind('arp',type(1))) || isempty(strfind('arp',type(2))) || isempty(strfind('arp',type(1))))
            pout.type=type;
        else
            message='Normalisation type for each axis must be ''r'', ''p'' or ''a''';
            ok=false; pout=default_proj(); return
        end
        if isempty(pout.w) && pout.type(3)=='p'
            message='Cannot have normalisation type ''p'' for third projection axis unless vector ''w'' is given';
            ok=false; pout=default_proj(); return
        end
        
    else
        message='Normalisation type must be a three character string, ''r'', ''p'' or ''a'' for each axis';
        ok=false; pout=default_proj(); return
    end
    
else
    if isempty(pout.w)
        pout.type='ppr';
    else
        pout.type='ppp';
    end
end


% uoffset
% -------
if isobject(p) || isfield(p,'uoffset')
    if isnumeric(p.uoffset) && (numel(p.uoffset)==3 || numel(p.uoffset)==4)
        if numel(p.uoffset)==3
            pout.uoffset=[p.uoffset(:);0];
        else
            pout.uoffset=p.uoffset(:);
        end
    else
        message='Vector uoffset must have form [h0,k0,l0] or [h0,k0,l0,en0]';
        ok=false; pout=default_proj(); return
    end
else
    pout.uoffset=zeros(4,1);
end


% Check labels
% ------------
if isobject(p) || isfield(p,'lab')
    % Can either give one or more of lab1, lab2,... as separate fields, or a single cell array with all four
    if isstruct(p) && (isfield(p,'lab1')||isfield(p,'lab2')||isfield(p,'lab3')||isfield(p,'lab4'))
        message = 'In projection description, either give one or more of lab1, lab2,... as separate fields, or a single cell array, lab, with all four labels';
        ok=false; pout=default_proj(); return
    end
    if iscellstr(p.lab) && numel(p.lab)==4
        pout.lab=p.lab(:)';   % ensure row cell array
    else
        message = 'In projection description, axes labels in ''lab'' must be a cell array of strings';
        ok=false; pout=default_proj(); return
    end

else
    pout.lab={'\zeta','\xi','\eta','E'};
    
    if isfield(p,'lab1')
        if ischar(p.lab1) && size(p.lab1,1)==1
            pout.lab{1}=p.lab1;
        else
            message = 'In projection description, check that label for axis 1 is a character string';
            ok=false; pout=default_proj(); return
        end
    end
    
    if isfield(p,'lab2')
        if ischar(p.lab2) && size(p.lab2,1)==1
            pout.lab{2}=p.lab2;
        else
            message = 'In projection description, check that label for axis 2 is a character string';
            ok=false; pout=default_proj(); return
        end
    end
    
    if isfield(p,'lab3')
        if ischar(p.lab3) && size(p.lab3,1)==1
            pout.lab{3}=p.lab3;
        else
            message = 'In projection description, check that label for axis 3 is a character string';
            ok=false; pout=default_proj(); return
        end
    end
    
    if isfield(p,'lab4')
        if ischar(p.lab4) && size(p.lab4,1)==1
            pout.lab{4}=p.lab4;
        else
            message = 'In projection description, check that label for axis 4 is a character string';
            ok=false; pout=default_proj(); return
        end
    end
end

%--------------------------------------------------------------------------------------------------
function pout=default_proj
% Return default proj structure
pout = struct('u', [1,0,0], 'v', [0,1,0], 'w', [], 'nonorthogonal', false, 'type', 'ppr',...
    'uoffset', [0,0,0,0]', 'lab', {{'','','',''}});
