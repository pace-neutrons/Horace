classdef projaxes
    % Object that defines the projection axes u1, u2, u3
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
    %   nonorthogonal  Indicates if non-orthogonal axes are permitted
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
    %                   'ppr'  if w not given
    %                   'ppp'  if w is given
    %
    %   uoffset     Row or column vector of offset of origin of projection axes (rlu)
    %
    %   lab         Short labels for u1,u2,u3,u4 as cell array
    %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
    %                   *OR*
    %   lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
    %   lab2        Short label for u2 axis
    %   lab3        Short label for u3 axis
    %   lab4        Short label for u4 axis (e.g. 'E' or 'En')
    
    
    % Original author: T.G.Perring
    %
    % $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
    
    
    properties(Dependent)
        % Row vector of first axis (r.l.u.) defining projection axes
        u
        % Row vector of second axis (r.l.u.) defining projection axes
        v
        % Row vector of third axis (r.l.u.) (set to [] if not given in proj_in)
        w
        % Column vector (length 4) of offset of origin of  projection axes (r.l.u. and en)
        uoffset
        % Character string length 3 defining normalisation. each character being 'a','r' or 'p' e.g. 'rrp'
        type
        % Indicates if non-orthogonal axes are permitted (if true)
        nonorthogonal
        % [1x4] cell array of projection axis labels
        lab
        % The property reports if the object is valid. It can become
        % invalid if some fields have been set up incorrectly after
        % creation (e.g. u set up parallel to v)
        valid
    end
    
    properties(Access=private)
        u_ = [1,0,0]
        v_ = [0,1,0]
        w_ = []
        nonorthogonal_=false
        type_='ppr'
        uoffset_ = [0;0;0;0]
        labels_={'Q_h', 'Q_k', 'Q_l', 'En'}
        % The property reports if the object is valid. It can become
        % invalid if some fields have been set up incorrectly after
        % creation (e.g. u set up parallel to v) See check_combo_arg_ for
        % all options which may be invalid
        valid_ = true
        % minimal value of projaxis norm e.g. how close to parallel
        % u, v and w allowed to be
        tol_=1e-12;
    end
    
    methods
        function [proj,mess] = projaxes(varargin)
            % projaxes class constructor
            if nargin == 0
                return
            end
            [proj,mess] = build_projaxes_(projaxes,varargin{:});
            if ~isempty(mess) && nargout < 2
                error('PROJAXES:invalid_argument',mess)
            end
            
        end
        
        % ----------------------------------------------------------------
        % getters/setters
        function u=get.u(obj)
            if obj.valid_
                u = obj.u_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    u = obj.u_;
                else
                    u = mess;
                end
            end
        end
        
        function obj = set.u(obj,val)
            obj = check_and_set_u_(obj,val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        
        %----------------------------------------------------------
        function v=get.v(obj)
            if obj.valid_
                v = obj.v_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    v = obj.v_;
                else
                    v = mess;
                end
            end
        end
        
        function obj = set.v(obj,val)
            obj = check_and_set_v_(obj,val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        
        %----------------------------------------------------------
        function w=get.w(obj)
            if obj.valid_
                w = obj.w_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    w = obj.w_;
                else
                    w = mess;
                end
            end
        end
        
        function obj = set.w(obj,val)
            obj = check_and_set_w_(obj,val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        
        %----------------------------------------------------------
        function uof=get.uoffset(obj)
            uof = obj.uoffset_;
        end
        
        function obj = set.uoffset(obj,val)
            obj = check_and_set_uoffset_(obj,val);
        end
        
        %----------------------------------------------------------
        function typ=get.type(obj)
            if obj.valid_
                typ = obj.type_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    typ = obj.type_;
                else
                    typ  = mess;
                end
            end
        end
        
        function obj=set.type(obj,type)
            obj = check_and_set_type_(obj,type);
            [~,~,obj] = check_combo_arg_(obj);
        end
        
        %----------------------------------------------------------
        function no=get.nonorthogonal(obj)
            no = obj.nonorthogonal_;
        end
        
        function obj=set.nonorthogonal(obj,val)
            if numel(val)>1
                error('PROJAXES:invalid_argument',...
                    ['nonorthogonal property value should be single value,'...
                    ' convertable to logical'])
            end
            obj.nonorthogonal_ = logical(val);
        end
        
        %----------------------------------------------------------
        function lab=get.lab(obj)
            lab = obj.labels_;
        end
        
        function obj=set.lab(obj,val)
            obj = check_and_set_labels_(obj,val);
        end
        
        %----------------------------------------------------------
        function is = get.valid(obj)
            is = obj.valid_;
        end
        
        % ----------------------------------------------------------------
        % Interfaces to public file methods
        [rlu_to_ustep, u_to_rlu, ulen, mess] = projaxes_to_rlu (proj, alatt, angdeg, ustep);
        
        
    end
end

