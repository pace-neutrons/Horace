classdef IX_moderator
    properties
        % Constructor for IX_moderator object
        %
        %   >> moderator = IX_moderator (distance,angle)
        %   >> moderator = IX_moderator (distance,angle,pulse_model,pp)
        %   >> moderator = IX_moderator (distance,angle,pulse_model,pp,flux_model,pf)
        %   >> moderator = IX_moderator (...,width,height)
        %   >> moderator = IX_moderator (...,width,height,thickness)
        %   >> moderator = IX_moderator (...,width,height,thickness,temperature)
        %
        %   >> moderator = IX_moderator (name,...)
        %
        % Original author: T.G.Perring
        name='' %            Name of the moderator (e.g. 'CH4')
        distance=0   %       Distance from sample (m) (+ve, against the usual convention)
        angle=0;     %       Angle of normal to incident beam (deg)
        %                  (positive if normal is anticlockwise from incident beam)
        pulse_model=''   %     Model for pulse shape (e.g. 'ikcarp')
        pp=[];           %              Parameters for the pulse shape model (array; length depends on pulse_model)
        flux_model=''    %      Model for flux profile (e.g. 'isis')
        pf=''            %              Parameters for the flux model (array; length depends on flux_model)
        width=0;         %  Width of moderator (m)
        height=0;        %  Height of moderator (m)
        thickness=0      % Thickness of moderator (m)
        temperature=0    % Temperature of moderator (K)
    end
    
    methods
        
        
        function w=IX_moderator(varargin)
            
            if nargin==0    % default constructor
                return
            elseif nargin==1 && isa(varargin{1},'IX_moderator')   % is a moderator object already
                w = varargin{1};
                return
                
            elseif nargin==1 && isstruct(varargin{1})    % structure
                w = varargin{1};
                [ok,mess,w]=checkfields(w);
                if ~ok, error(mess), return, end
                
            else
                if isstring(varargin{1})
                    w.name = varargin{1};
                    noff=1;
                else
                    w.name = '';
                    noff=0;
                end
                if any(nargin-noff==[2,4,6,8,9,10])
                    w.distance  = varargin{noff+1};
                    w.angle = varargin{noff+2};
                    if nargin-noff>=4
                        w.pulse_model = varargin{noff+3};
                        w.pp = varargin{noff+4};
                    else
                        w.pulse_model = '';
                        w.pp = [];
                    end
                    if nargin-noff>=6
                        w.flux_model = varargin{noff+5};
                        w.pf = varargin{noff+6};
                    else
                        w.flux_model = '';
                        w.pf = [];
                    end
                    if nargin-noff>=8
                        w.width = varargin{noff+7};
                        w.height= varargin{noff+8};
                    else
                        w.width = 0;
                        w.height= 0;
                    end
                    if nargin-noff>=9
                        w.thickness = varargin{noff+9};
                    else
                        w.thickness = 0;
                    end
                    if nargin-noff>=10
                        w.temperature = varargin{noff+10};
                    else
                        w.temperature = 0;
                    end
                else
                    error('Check number of input arguments')
                end
                [ok,mess,w]=checkfields(w);
                if ~ok, error(mess), return, end
                
            end
            
            
        end
    end
end