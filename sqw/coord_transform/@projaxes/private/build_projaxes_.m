function [obj,mess] = build_projaxes_(obj,varargin)
% Create projaxes object that defines the projection axes u1, u2, u3
%
% Structure input:
%   >> proj = projaxes(proj_struct)
%
% Argument input:
%   >> proj = projaxes(u,v)
%   >> proj = projaxes(u,v,w)
%
%   and any of the optional arguments:
%
%   >> proj = projaxes(...,'nonorthogonal',nonorthogonal,..)
%   >> proj = projaxes(...,'type',type,...)
%   >> proj = projaxes(...,'uoffset',uoffset,...)
%   >> proj = projaxes(...,'lab',labelcellstr,...)
%   >> proj = projaxes(...,'lab1',labelstr,...)
%                   :
%   >> proj = projaxes(...,'lab4',labelstr,...)
%
% Input:
% ------
% Projection axes are defined by two vectors in reciprocal space, together
% with optional arguments that control normalisation, orthogonality, labels etc.
% The input can be a data structure with fieldnames and contents chosen from
% the arguments below, or alternatively the arguments
%
% Required arguments:
%   u           [1x3] Vector of first axis (r.l.u.) defining projection axes
%   v           [1x3] Vector of second axis (r.l.u.) defining projection axes
%
% Optional arguments:
%   w           [1x3] Vector of third axis (r.l.u.) - only needed if the third
%               character of argument 'type' is 'p'. Will otherwise be ignored.
%
%   nonorthogonal Indicate if non-orthogonal axes are permitted
%               If false (default): construct orthogonal axes u1,u2,u3 from u,v
%               by defining: u1 || u; u2 in plane of u and v but perpendicular
%               to u with positive component along v; u3 || u x v
%
%               If true: use u,v (and w, if given) as non-orthogonal projection
%               axes: u1 || u, u2 || v, u3 || w if given, or u3 || u x v if not.
%
%   type        [1x3] Character string defining normalisation. Each character
%               indicates how u1, u2, u3 are normalised, as follows:
%               - if 'a': projection axis unit length is one inverse Angstrom
%               - if 'r': then if ui=(h,k,l) in r.l.u., is normalised so
%                         max(abs(h,k,l))=1
%               - if 'p': if orthogonal projection axes:
%                               |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                           i.e. the projections of u,v,w along u1,u2,u3 match
%                           the lengths of u1,u2,u3
%
%                         if non-orthogonal axes:
%                               u1=u;  u2=v;  u3=w
%               Default:
%                 	'ppr'  if w not given
%                 	'ppp'  if w is given
%
%	uoffset     Row or column vector of offset of origin of projection axes (rlu)
%
%   lab         Short labels for u1,u2,u3,u4 as cell array
%               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                   *OR*
%   lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%   lab2        Short label for u2 axis
%   lab3        Short label for u3 axis
%   lab4        Short label for u4 axis (e.g. 'E' or 'En')
%
%
% Output:
% -------
%   proj        projaxes object with defaults for absent fields
%           proj.u              [1x3] Vector of first axis (r.l.u.)
%           proj.v              [1x3] Vector of second axis (r.l.u.)
%           proj.w              [1x3] Vector of third axis (r.l.u.)
%                               (set to [] if not given in proj_in)
%           proj.nonorthogonal  logical true or false
%           proj.type           [1x3] Char. string defining normalisation
%                               each character being 'a','r' or 'p' e.g. 'rrp'
%           proj.uoffset        [4x1] column vector of offset of origin of
%                               projection axes (r.l.u. and en)
%           proj.labels         [1x4] cell array of projection axis labels


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

mess='';
proj_in = [];
narg=nargin;
if narg==1  % default projaxes
    return;
elseif narg==2 && isa(varargin{1},'projaxes')
    obj=varargin{1};  % invoke copy constructor
    return
elseif narg==2 && isstruct(varargin{1})
    if isscalar(varargin{1})
        proj_in=varargin{1};
    else
        mess='If input argument is a structure, it must be a scalar structure';
        return
    end
else % parse positional and keyword-defined variables provided in sequence
    arglist = struct('nonorthogonal', [], 'type', [],...
        'uoffset', [], 'lab', [], 'lab1', [], 'lab2', [], 'lab3', [], 'lab4', []);
    [par,argout,present,~,ok,mess] = parse_arguments(varargin,arglist);
    if ok
        if numel(par)<=3
            if numel(par)==1
                obj = check_and_set_u_(obj,par{1});
            elseif numel(par)==2
                obj = check_and_set_u_(obj,par{1});
                obj = check_and_set_v_(obj,par{2});
            elseif numel(par)==3
                obj = check_and_set_u_(obj,par{1});
                obj = check_and_set_v_(obj,par{2});
                obj = check_and_set_w_(obj,par{3});
            end
            nam=fieldnames(argout);
            proj_in =rmfield(argout,nam(~cell2mat(struct2cell(present))));                
            if numel(fieldnames(proj_in)) == 0
                proj_in = [];
            end
        else
            mess='Check number and type of input arguments';
            return
        end
    end
    
end

% Check fields, or get default structure if an error
if ~isempty(proj_in)
    [mess,obj]=check_and_set_opt_fields_(obj,proj_in);
end
if isempty(mess)
    [~,mess,obj] = check_combo_arg_(obj);
end
