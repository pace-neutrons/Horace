classdef test_He3tube_3
    %   narg it
    %
    % Wotsit Methods:
    %

    %---------------------------------------------------------------------------
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
    %---------------------------------------------------------------------------


    % Original author: T.G.Perring
    %

    properties (Access=private)
        %   Hi there!!
        %
        %   I missed you!!
        % Really!
        % truly!
        % Honest!

        %-----------------------------------------------------------------------
        % <#doc_beg:> miggle
        %   Hi there!!
        %
        %   I missed you!!

        % Really!
        % truly!
        % Honest!
        % <#doc_end:>
        %-----------------------------------------------------------------------

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
        function obj=test_He3tube_3(dia,atms,thick)
            % Constructor for He3tube object
            %
            %   >> obj=He3tube(dia,atms,thick)
            %
            % Input:
            % ------
            %   dia     [Optional] Outer diameter of tube (m)
            %           Default: zero
            %   atms    [Optional] 3He partial pressure (atmospheres)
            %           Default: zero
            %   thick   [Optional] Wall thickness (m)
            %           Default: zero

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
            % Really!
            % truly!
            % Honest!

            %-------------------------------------------------------------------
            % <#doc_beg:> miggle


            % Really!
            % truly!
            % Honest!
            % <#doc_end:>
            %-------------------------------------------------------------------
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

