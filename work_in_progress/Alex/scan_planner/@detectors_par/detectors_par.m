classdef detectors_par
 %file describles angular positions of instrument's detectors
 %
 %Usage:
 %>>det=detectors()               % build empty detectors
 %>>det=detectors(file_name) % build detectrors from par or phx file
 %>>det=detectors(par)           % build detectors from properly formatted
 %                                              parameters array
 %>>det=detectors(numel,fi_min,fi_max) % build test detector's file
 % where
 %   numel     -- number of test detectors
 %  fi_min      -- minimal detector angle in fi-direction (deg)
 %                   default: -60;
 %  fi_max      -- maximal detector angle in fi-direction
%                      default: +20
    
    properties(GetAccess='public', SetAccess='private') 
% data has following fields:
      filename='';  %  Name of file excluding path
      filepath='';   % Path to file including terminating file separator
      x2       =[];  %    Secondary flightpath (m)
      group  =[];   %    Row vector of detector group number - assumed to be 1:ndet
       phi     =[];   %    Row vector of scattering angles (deg)
       azim  =[];   %     Row vector of azimuthal angles (deg)                  (West bank=0 deg, North bank=90 deg etc.)
       width =[];      %  Row vector of detector widths (m)
       height=[];     %  Row vector of detector heights (m)

    end
    properties(GetAccess='private', SetAccess='private') 
        phi_min=-60;
        phi_max=20;
    end
%% -----------------------------------------------------------------------------------------------------------------
    methods
        function this=detectors_par(data_or_file,varargin)
            if ~exist('data_or_file','var')
                return;
            end
%% FILE SUPPLIED            
            if ischar(data_or_file)
                % Remove blanks from beginning and end of filename
                file_name=strtrim(data_or_file);

            % Get file name and path (incl. final separator)
                [path,name,ext]=fileparts(file_name);
                this.filename=[name,ext];
                this.filepath = [path,filesep];   
                if nargin>1
                    if ischar(varargin{1})
                        key = varargin{1};
                        if strcmpi(key,'-load')
                            this=load_par(this);
                        else
                            error('DETECTORS_PAR:constructor',' unrecognized option: %s',key);
                        end
                    end
                end
            else
 %% DATA SUPPLIED        
                % if an array is supplied;
                if isa(data_or_file,'double')&&numel(data_or_file)>1
                    if size(data_or_file,1)==5
                        ndet        = size(data_or_file,2);
                        this.group=1:ndet;
                        this.x2=data_or_file(1,:);
                        this.phi=data_or_file(2,:);
                        this.azim=-data_or_file(3,:); % Note sign change to get correct convention
                        this.width=data_or_file(4,:);
                        this.height=data_or_file(5,:);                        
                        
                        % 
                        this.phi_min  = min(this.phi);
                        this.phi_max = max(this.phi);                        
                    else
                        help detectors_par.m;
                        error('DETECTORS_PAR:constructor',' wrong input parameters');
                    end
                else
                    % we generate test data; 
                    if data_or_file>0
                        if nargin>=1
                            this.phi_min=varargin{1};
                        end
                        if nargin>=2
                            this.phi_max=varargin{2};                            
                        end
                        this = build_test_detectors(this,data_or_file);
                    end
                end
            end            
        end
 %% ---------------------------------------------------------------------------------------------------------------- 
        function ndet=getNDetectors(this)
            ndet = numel(this.phi);
        end
 %% ---------------------------------------------------------------------------------------------------------------- 
        function det=getDetStruct(this)
             det.filename=this.filename;
             det.filepath  =this.filepath;   % Path to file including terminating file separator
             det.x2         =this.x2;  %    Secondary flightpath (m)
             det.group    =this.group;   %    Row vector of detector group number - assumed to be 1:ndet
             det.phi        =this.phi;   %    Row vector of scattering angles (deg)
             det.azim     =this.azim;   %     Row vector of azimuthal angles (deg)                  (West bank=0 deg, North bank=90 deg etc.)
             det.width    =this.width;      %  Row vector of detector widths (m)
             det.height   =this.height;     %  Row vector of detector heights (m)
        end
        function par=getDetPar(this)
            par=zeros(5,getNDetectors(this));
              
            par(1,:)= this.x2;
            par(2,:)=  this.phi;
            par(3,:)= -this.azim; % Note sign change to get correct convention
            par(4,:)= this.width;
            par(5,:)= this.height;
        end
    end
    
end

