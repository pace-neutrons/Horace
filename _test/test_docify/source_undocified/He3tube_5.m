classdef test_He3tube_5
    %He3tube Defines cylindrical 3He detector
    %   Defines cylindrical 3He gas tube properties on which efficiency,
    %   depth of absortption etc depend, namely diameter, wall thickness
    %   partial pressure of 3He. It does not define pixellation or
    %   length of tube - those preoperties are considered geometric
    %   properties that belong elsewhere.
    
    % <#doc_def:>
    %
    %   class_name = 'Wotsit'
    %
    % <#doc_beg:> multifit
    %   narg it
    %
    % <class_name> Methods:
    %
    % <#doc_end:>
    
    
    % Original author: T.G.Perring
    %
    % $Revision$ ($Date$)
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        
        % <#doc_beg:> miggle
        
        % Really!
        % truly!
        % Honest!
        % <#doc_end:>
        
        %-------------------------------------
        % Now another block
        %-------------------------------------
        
        % <#doc_def:>
        %
        %   class_name = 'Wotsit'
        %
        % <#doc_beg:> multifit
        %   narg it
        %
        % <class_name> Methods:
        %
        % <#doc_end:>
        
        % This is a p[ile of crap which is my
        % way of sayin ipsum lorem
        
        dia_=0;     % Outer diameter of tube (m)
        atms_=0;    % 3He partial pressure (atmospheres)
        thick_=0;   % Wall thickness (m)
    end
    
    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        atms        % 3He partial pressure (atmospheres)
        thick       % Wall thickness (m)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties
        inner_rad   % Inner radius of tube(m)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=test_He3tube_5(dia,atms,thick)
            % Stuff that should go
            % indeedy
            % doody
            
            % <#doc_def:>
            %   first_line = {'% Simultaneously fits a function to several datasets, with optional',...
            %                 '% background functions.'}
            %   main = true;
            %   method = false;
            %   synonymous = false;
            %
            %   multifit=true;
            %   func_prefix='multifit';
            %   func_suffix='';
            %   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
            %
            %   custom_keywords = false;
            %
            % <#doc_beg:>
            %   <#file:> meta_docs:::doc_multifit_short.m
            %
            %
            %   <#file:> meta_docs:::doc_multifit_long.m
            %
            %
            %   <#file:> meta_docs:::doc_multifit_examples_1d.m
            % <#doc_end:>
            
            if nargin>=1
                obj.dia=dia;
            end
            if nargin>=2
                obj.atms=atms;
            end
            if nargin>=3
                obj.thick=thick;
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        function obj=set.dia(obj,dia)
            % <#doc_beg:> miggle
            
            
            % Really!
            % truly!
            % Honest!
            % <#doc_end:>
            if dia>=2*obj.thick_
                obj.dia_=dia;
            else
                error('Tube diameter must be greater or equal to twice the wall thickness')
            end
        end
        
        function obj=set.atms(obj,atms)
            if atms>=0
                obj.atms_=atms;
            else
                error('Partial pressure of 3He must be >= 0')
            end
        end
        
        function obj=set.thick(obj,thick)
            if thick<=obj.dia_/2
                obj.thick_=thick;
            else
                error('Tube wall thickness must be less than or equal to the diameter')
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function dia=get.dia(obj)
            dia=obj.dia_;
        end
        
        function atms=get.atms(obj)
            atms=obj.atms_;
        end
        
        function thick=get.thick(obj)
            thick=obj.thick_;
        end
        
        function inner_rad=get.inner_rad(obj)
            inner_rad=0.5*obj.dia_ - obj.thick_;
        end
        %------------------------------------------------------------------
        
    end
    
end

