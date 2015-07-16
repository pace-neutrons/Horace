function [self, mess] = proj_fill_fields (self,proj_in)
% Fill the fields of proj class from input and defaults for missing information
%
% Input:
%   proj_in Data structure containing details of projection axes:
%           Defines two vectors u and v that give the direction of u1
%           (parallel to u) and u2 (in the plane of u1 and u2, with u2
%           having positive component along v); also defines the 
%           normalisation of u1,u2,u3
%             Required arguments:
%               proj.u          [1x3] Vector of first axis (r.l.u.)
%               proj.v          [1x3] Vector of second axis (r.l.u.)
%             Optional arguments:
%               proj.w          [1x3] Vector of third axis (r.l.u.) - only needed if third character of type is 'p'
%                               Will otherwise be ignored.
%               proj.type       [1x3] Char. string defining normalisation:
%                   Each character indicates if u1, u2, u3 normalised as follows:
%                   - if 'a': unit length is one inverse Angstrom
%                   - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs(h,k,l))=1
%                   - if 'p': then normalised so that if the orthogonal set created from u and v is u1, u2, u3:
%                       |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                      i.e. the projections of u,v,w along u1,u2,u3 match the lengths of u1,u2,u3
%                   Default:
%                       'ppr'  if w not given
%                       'ppp'  if w is given
%               proj.uoffset    Row or column vector of offset of origin of projection axes (r.l.u.)
%               proj.lab        Short labels for u1,u2,u3,u4 as cell array (e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                  *OR*
%               proj.lab1       Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%               proj.lab2       Short label for u2 axis
%               proj.lab3       Short label for u3 axis
%               proj.lab4       Short label for u4 axis (e.g. 'E' or 'En')
%
% Output:
%   proj    Output data structure with defaults for absent fields (note that labels packed as single cellstr)
%              proj.u          [1x3] Vector of first axis (r.l.u.)
%              proj.v          [1x3] Vector of second axis (r.l.u.)
%           Optional arguments:
%              proj.w          [1x3] Vector of third axis (r.l.u.) (set to [] if not given in proj_in)
%              proj.type       [1x3] Char. string defining normalisation:
%              proj.uoffset    [4x1] column vector of offset of origin of projection axes (r.l.u. and en)
%              proj.lab        [1x4] cell array of projection axis labels

% T.G.Perring 24 July 2007


mess = '';

% Check definition of projection axes
if (isfield(proj_in,'u') && isa_size(proj_in.u,[1,3],'double')) && (isfield(proj_in,'v') && isa_size(proj_in.v,[1,3],'double'))
    self.u = proj_in.u;
    self.v = proj_in.v;
else
    self = [];
    mess = 'Check that projection description contains fields u and v that are both three-vectors in r.l.u.';
    return
end

% Check optional vector w
if isfield(proj_in,'w')
    if isa_size(proj_in.w,[1,3],'double')
        self.w = proj_in.w;
    elseif isempty(proj_in.w)
        self.w=[];  % will be recognised as meaning unassigned in code that uses proj structure
    else
        self = [];
        mess = 'If given, the projection description field w must be a three-vector in r.l.u., (or empty)';
        return
    end
else
    self.w=[];  % will be recognised as meaning unassigned in code that uses proj structure
end

% Check normalisation type
if isfield(proj_in,'type')
    if isa_size(proj_in.type,[1,3],'char')
        self.type = lower(proj_in.type);
        if isempty(strfind('arp',proj_in.type(1)))||isempty(strfind('arp',proj_in.type(2)))||isempty(strfind('arp',proj_in.type(3)))
            self = [];
            mess = 'In projection description, normalisation type for each axis must be ''a'', ''r'' or ''p''';
            return
        end
        if isempty(self.w) && self.type(3)=='p'
            self= [];
            mess = 'In projection description, must give third axis, w, if normalisation of third axis is ''p''';
            return
        end
    else
        self = [];
        mess = 'Check that normalisation type in the projection description is a three character string';
        return
    end
else
    if isempty(self.w)
        self.type = 'ppr';  % default value
    else
        self.type = 'ppp';
    end
end

% Check uoffset
if isfield(proj_in,'uoffset')
    if isa(proj_in.uoffset,'double') && isvector(proj_in.uoffset) && (length(proj_in.uoffset)==3||length(proj_in.uoffset)==4)
        n = length(proj_in.uoffset);
        self.uoffset = zeros(4,1);          % default value column vector
        self.uoffset(1:n)= proj_in.uoffset; % fill with values from input (energy offset will by default be zero)
    else
        self=[];
        mess = 'Check that uoffset in the projection description has form (qh0,qk0,ql0) or (qh0,qk0,ql0,en0)';
        return
    end
else
    self.uoffset = zeros(4,1);  % default value
end

% Check labels
self.lab = {'\zeta','\xi','\eta','E'};

if isfield(proj_in,'lab')
    % Can either give one or more of lab1, lab2,... as separate fields, or a single cell array with all four
    if isfield(proj_in,'lab1')||isfield(proj_in,'lab2')||isfield(proj_in,'lab3')||isfield(proj_in,'lab4')
        self=[];
        mess = 'In projection description, either give one or more of lab1, lab2,... as separate fields, or a single cell array, lab, with all four labels';
        return
    end
    if iscellstr(proj_in.lab)
        self.lab=proj_in.lab(:)';   % ensure row cell array
    else
        self=[];
        mess = 'In projection description, axes labels must all be character strings';
        return
    end

else
    if isfield(proj_in,'lab1')
        if ischar(proj_in.lab1) && size(proj_in.lab1,1)==1
            self.lab{1}=proj_in.lab1;
        else
            self = [];
            mess = 'In projection description, check that label for axis 1 is a character string';
            return
        end
    end

    if isfield(proj_in,'lab2')
        if ischar(proj_in.lab2) && size(proj_in.lab2,1)==1
            self.lab{2}=proj_in.lab2;
        else
            self = [];
            mess = 'In projection description, check that label for axis 2 is a character string';
            return
        end
    end

    if isfield(proj_in,'lab3')
        if ischar(proj_in.lab3) && size(proj_in.lab3,1)==1
            self.lab{3}=proj_in.lab3;
        else
            self = [];
            mess = 'In projection description, check that label for axis 3 is a character string';
            return
        end
    end

    if isfield(proj_in,'lab4')
        if ischar(proj_in.lab4) && size(proj_in.lab4,1)==1
            self.lab{4}=proj_in.lab4;
        else
            self = [];
            mess = 'In projection description, check that label for axis 4 is a character string';
            return
        end
    end

end
