function [message, obj] = check_and_set_opt_fields_(obj,p)
% Check validity of optional fields for an object
%
%   >> [ok, message,wout] = check_and_set_opt_fields_(w)
%
%   w       structure or object of the class
%
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

message = '';
if ~all(ismember(fieldnames(p),[fieldnames(default_proj);{'lab1';'lab2';'lab3';'lab4'}]))
    message='One or more unrecognised fields passed in projection description';
    return
end
if isfield(p,'u')
    obj = check_and_set_u_(obj,p.u);
end
if isfield(p,'v')
    obj = check_and_set_v_(obj,p.v);
end
if isfield(p,'w')
    obj = check_and_set_w_(obj,p.w);
end



% Check orthogonality
% -------------------
if isfield(p,'nonorthogonal')
    obj.nonorthogonal = p.nonorthogonal;
end


% Normalisation type
% ------------------
if isfield(p,'type') && ~isempty(p.type)
    obj = check_and_set_type_(obj,p.type);
else
    if isempty(obj.w)
        obj = check_and_set_type_(obj,'ppr');
    else
        obj = check_and_set_type_(obj,'ppp');
    end
end


% uoffset
% -------
if isfield(p,'uoffset')
    obj = check_and_set_uoffset_(obj,p.uoffset);
end

% Check labels
% ------------
if isfield(p,'lab')
    % Can either give one or more of lab1, lab2,... as separate fields, or a single cell array with all four
    if isstruct(p) && (isfield(p,'lab1')||isfield(p,'lab2')||isfield(p,'lab3')||isfield(p,'lab4'))
        message = 'In projection description, either give one or more of lab1, lab2,... as separate fields, or a single cell array, lab, with all four labels';
        return;
    end
    obj.lab = p.lab;
else
    obj.lab={'\zeta','\xi','\eta','E'};
    
    if isfield(p,'lab1')
        if ischar(p.lab1) && size(p.lab1,1)==1
            obj.lab{1}=p.lab1;
        else
            message = 'In projection description, check that label for axis 1 is a character string';
            return
        end
    end
    
    if isfield(p,'lab2')
        if ischar(p.lab2) && size(p.lab2,1)==1
            obj.lab{2}=p.lab2;
        else
            message = 'In projection description, check that label for axis 2 is a character string';
            return
        end
    end
    
    if isfield(p,'lab3')
        if ischar(p.lab3) && size(p.lab3,1)==1
            obj.lab{3}=p.lab3;
        else
            message = 'In projection description, check that label for axis 3 is a character string';
            return
        end
    end
    
    if isfield(p,'lab4')
        if ischar(p.lab4) && size(p.lab4,1)==1
            obj.lab{4}=p.lab4;
        else
            message = 'In projection description, check that label for axis 4 is a character string';
            return
        end
    end
end

%--------------------------------------------------------------------------------------------------
function pout=default_proj
% Return default proj structure
pout = struct('u',[1,0,0],'v',[0,1,0],'w',[],'nonorthogonal', false, 'type', 'ppr',...
    'uoffset', [0,0,0,0]', 'lab', {{'','','',''}});
