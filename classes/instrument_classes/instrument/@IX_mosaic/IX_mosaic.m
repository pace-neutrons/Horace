classdef IX_mosaic
    % Mosaic spread object
    
    properties (Constant, Access=private)
        shapes_ = fixedNameList({'point','cuboid'})   % valid sample types
        n_ps_ = containers.Map({'point','cuboid'},[0,3]) % number of parameters for sample description
    end
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        class_version_ = 1;
        xaxis_ = [1,0,0];
        yaxis_ = [0,1,0];
        mosaic_pdf_ = @rand_mosaic_gaussian;
        parameters_ = 0;
        valid_ = true;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        xaxis
        yaxis
        mosaic_pdf
        parameters
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mosaic (varargin)
            % Create sample object
            %
            %   >> mosaic = IX_mosaic (xaxis, yaxis, mosaic_pdf, parameters)
            %
            % Default Gaussian mosaic spread:
            % - isotropic Gaussian (fwhh_deg a scalar):
            %   >> mosaic = IX_mosaic (fwhh_deg)
            %
            % - anisotropic Gaussian (fwhh_deg a 3-vector, or 3x3 matrix)
            %   >> mosaic = IX_mosaic (xaxis, yaxis, fwhh_deg)
            %
            % - generic mosaic function with default xaxis and yaxis
            %   >> mosaic = IX_mosaic (mosaic_pdf, parameters)
            %
            %
            %   xaxis           Direction of x-axis of rotation matrix description
            %                   A vector in reciprocal lattice units
            %                   Default: [1,0,0]
            %
            %   yaxis           Direction of y-axis of rotation matrix description
            %                   A vector in reciprocal lattice units.
            %                   Default: [0,1,0]
            %
            %                   xaxis and yaxis together define the orinetation
            %                   of the orthonormal frame in which the random
            %                   rotation vectors produced by the mosaic function
            %                   below are expressed
            %
            %                   The frame is defined in the usual way: the x-axis
            %                   is along xaxis; the y-axis is in the plane of
            %                   xaxis and yaxis perpendicular to xaxis and with
            %                   a positive component along yaxis; the z-axis is
            %                   perpendicular to the x-axis and y-axis in the
            %                   right-handed sense.
            %
            %   mosaic_pdf      Mosaic spread distribution function that
            %                   returns random rotation vectors. Function handle.
            %
            %                   Default: @rand_mosaic_gaussian
            %
            %                   The mosaic spread function must have the form:
            %                       V = my_random_vectors (object, sz, p1, p2,...)
            %                   where:
            %                       object      IX_mosaic object
            %                       sz          Size vector for output
            %                       p1, p2, ... Parameters for the pdf
            %
            %                       V           Array size [3,sz] of rotation
            %                                   vectors. If sz starts with a leading
            %                                   singleton, this is suppressed e.g.
            %                                   if sz=[1,7] then size(V) = [3,7]
            %
            %                   EXAMPLE:
            %                       V = my_lorentzian_mosaic (sz, fwhh_deg)
            %                   and set
            %                       mosaic_pdf
            %
            %
            %   parameters      Parameters for the mosaic spread function above:
            %                   Single, non-cell array argument p1:
            %                       parameters = p1
            %
            %                   Single cell array argument p1:
            %                       parameters = {p1}   % to avoid ambiguity with general form
            %
            %                   General form:
            %                       parameters = {p1, p2,...}
            %
            %                   EXAMPLE For the function mosaic_lorentzian above, the
            %                   value of parameters is simply fwhh_deg:
            %                       >> mos = IX_mosaic (@my_lorentzian_mosaic, fwhh_deg)
            %
            %
            %
            % The default is a Gaussian mosaic spread defined by the full widdth
            % half height in degrees:
            %   - fwhh                      Isotropic Gaussian mosaic spread
            %                               There is no need to give
            %
            %   - [fwhh_x,fwhh_y,fwhh_z]    Mosaic with fwhh (deg) rotation about
            %                               each of the x,y,z axes
            %
            %   - (fwhh_array).^2 (size=[3x3]) Mosaic matrix that incorporates
            %                               correlations between the axes:
            %                               - diagonals are fwhh^2
            %                               - off-diagonal are corresponding
            %                                 cross-correlations
            %                               The matrix is just the covariance
            %                               matrix, multipied by log(256) so
            %                               that the elements are scaled to
            %                               refer to FWHH
            %
            %
            % Note: the default function is an isotropic gaussian mosaic spread.
            % Only the fwhh of the mosaic spread needs to be given in this case.
            % There is no need to specify the x and y axes for the
            
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_mosaic.loadobj(varargin{1});
                
            elseif nargin>0 && nargin<=4
                if nargin==1
                    [ok,mess,val_out] = check_mosaic_matrix (varargin{1});
                    if ~ok, error(mess), end
                    obj.parameters_ = val_out;
                    
                elseif nargin==2
                    obj.mosaic_pdf_ = varargin{1};
                    if ~iscell(varargin{2})
                        obj.parameters_ = varargin{2};
                    else
                        obj.parameters_ = varargin{2}(:)';
                    end
                    
                elseif nargin==3 || nargin==4
                    obj.xaxis_ = varargin{1};
                    obj.yaxis_ = varargin{2};
                    [ok,mess] = check_xyaxis (obj.xaxis_,obj.yaxis_);
                    if ~ok, error(mess), end
                    
                    if nargin==3
                        [ok,mess,val_out] = check_mosaic_matrix (varargin{3});
                        if ~ok, error(mess), end
                        obj.parameters_ = val_out;
                    end
                    
                    if nargin==4
                        obj.mosaic_pdf_ = varargin{3};
                        if ~iscell(varargin{4})
                            obj.parameters_ = varargin{4};
                        else
                            obj.parameters_ = varargin{4}(:)';
                        end
                    end
                    
                else
                    error('Check the number of input arguments')
                    
                end
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods
        %
        % Set the non-dependent properties. We cannot make the set
        % functions depend on other non-dependent properties (see Matlab
        % documentation). Have to devolve any checks on interdependencies to the
        % constructor (where we refer only to the non-dependent properties)
        % and in the set functions for the dependent properties. There is a
        % synchronisation that must be maintained as the checks in both places
        % must be identical.
        
        function obj=set.xaxis_(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.xaxis_=val(:)';
            else
                error('''xaxis'' must be a three-vector')
            end
        end
        
        function obj=set.yaxis_(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.yaxis_=val(:)';
            else
                error('''yaxis'' must be a three-vector')
            end
        end
        
        function obj=set.mosaic_pdf_(obj,val)
            if isscalar(val) && isa(val,'function_handle')
                obj.mosaic_pdf_ = val;
            else
                error('Mosaic distribution function must be a function handle')
            end
        end
        
        function obj=set.parameters_(obj,val)
            obj.parameters_ = val;
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        
        function obj=set.xaxis(obj,val)
            obj.xaxis_=val;
            [ok,mess] = check_xyaxis (obj.xaxis_,obj.yaxis_);
            if ~ok, error(mess), end
        end
        
        function obj=set.yaxis(obj,val)
            obj.yaxis_=val;
            [ok,mess] = check_xyaxis (obj.xaxis_,obj.yaxis_);
            if ~ok, error(mess), end
        end
        
        function obj=set.mosaic_pdf(obj,val)
            obj.mosaic_pdf_=val;
        end
        
        function obj=set.parameters(obj,val)
            obj.parameters_=val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.xaxis(obj)
            val=obj.xaxis_;
        end
        
        function val=get.yaxis(obj)
            val=obj.yaxis_;
        end
        
        function val=get.mosaic_pdf(obj)
            val=obj.mosaic_pdf_;
        end
        
        function val=get.parameters(obj)
            val=obj.parameters_;
        end
        
        %------------------------------------------------------------------
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code; it calls a class-specific function
            % called init_from_structure_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called iniSt_from_structure_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

%------------------------------------------------------------------
% Utility functions to check dependent properties
%------------------------------------------------------------------
function [ok,mess] = check_xyaxis (x,y)
% Check non-colinearity. Assume x, y are each either three-vectors or empty
ok = true;
mess = '';
if ~(isempty(x) || isempty(y))
    if norm(cross(x,y))/(norm(x)*norm(y)) < 1e-5
        ok = false;
        mess='''xaxis'' and ''yaxis'' are colinear, or almost colinear';
    end
end
end
