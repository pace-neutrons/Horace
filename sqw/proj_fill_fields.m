function [proj, mess] = proj_fill_fields (proj_in)
% Fill the fields of proj data sstructure from input and defaults for missing information
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
%               proj.type       [1x3] Char. string defining normalisation:
%                  [each character indicates if u1, u2, u3 normalised to Angstrom^-1 ('a'), or
%                   r.l.u., max(abs(h,k,l))=1 ('r');  e.g. type='arr']
%                   Default: 'rrr'
%               proj.uoffset    Row or column vector of offset of origin of projection axes (r.l.u.)
%               proj.lab1       Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%               proj.lab2       Short label for u2 axis
%               proj.lab3       Short label for u3 axis
%               proj.lab4       Short label for u4 axis (e.g. 'E' or 'En')
%
% Output:
%   proj    Output data structure; similar, but not identical to input:
%              proj.u          [1x3] Vector of first axis (r.l.u.)
%              proj.v          [1x3] Vector of second axis (r.l.u.)
%           Optional arguments:
%              proj.type       [1x3] Char. string defining normalisation:
%                  [each character indicates if u1, u2, u3 normalised to Angstrom^-1 ('a'), or
%                   r.l.u., max(abs(h,k,l))=1 ('r');  e.g. type='arr']
%                  Default: 'rrr'
%              proj.uoffset    [1x4] column vector of offset of origin of projection axes (r.l.u. and en)
%              proj.ulab       [1x4] cell array of projection axis labels

% T.G.Perring 24 July 2007


mess = '';

% Check definition of projection axes
if (isfield(proj_in,'u') && isa_size(proj_in.u,[1,3],'double')) && (isfield(proj_in,'v') && isa_size(proj_in.v,[1,3],'double'))
    proj.u = proj_in.u;
    proj.v = proj_in.v;
else
    proj = [];
    mess = 'Check that projection description contains fields u and v that are both three-vectors in r.l.u.';
    return
end

% Check normalisation type
proj.type = 'rrr';  % default value
if isfield(proj_in,'type')
    if isa_size(proj_in.type,[1,3],'char')
        proj.type = proj_in.type;
    else
        proj = [];
        mess = 'Check that normalisation type in the projection description is a three character string';
        return
    end
end

% Check uoffset
proj.uoffset = zeros(4,1);  % default value
if isfield(proj_in,'uoffset')
    if isa(proj_in.uoffset,'double') && isvector(proj_in.uoffset) && (length(proj_in.uoffset)==3||length(proj_in.uoffset)==4)
        n = length(proj_in.uoffset);
        proj.uoffset(1:n)= proj_in.uoffset;
    else
        proj=[];
        mess = 'Check that uoffset in the projection description has form (qh0,qk0,ql0) or (qh0,qk0,ql0,en0)';
        return
    end
end

% Check labels
proj.ulab = {'Q_1','Q_2','Q_3','E'};

if isfield(proj_in,'lab1')
    if ischar(proj_in.lab1) && size(proj_in.lab1,1)==1
        proj.ulab{1}=proj_in.lab1;
    else
        proj = [];
        mess = 'Check that label for axis 1 is a character string';
        return
    end
end

if isfield(proj_in,'lab2')
    if ischar(proj_in.lab2) && size(proj_in.lab2,1)==1
        proj.ulab{2}=proj_in.lab2;
    else
        proj = [];
        mess = 'Check that label for axis 2 is a character string';
        return
    end
end

if isfield(proj_in,'lab3')
    if ischar(proj_in.lab3) && size(proj_in.lab3,1)==1
        proj.ulab{3}=proj_in.lab3;
    else
        proj = [];
        mess = 'Check that label for axis 3 is a character string';
        return
    end
end

if isfield(proj_in,'lab4')
    if ischar(proj_in.lab4) && size(proj_in.lab4,1)==1
        proj.ulab{4}=proj_in.lab4;
    else
        proj = [];
        mess = 'Check that label for axis 4 is a character string';
        return
    end
end

