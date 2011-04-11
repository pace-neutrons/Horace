classdef sample
% the class describes a cell of crystalline lattice and reciprocal lattice
% for the same crystall (or powder?)

   properties(GetAccess='public', SetAccess='private')    
       % direct lattice parameters
       lattice_param=[2.87,2.87,2.87];
       % angles between the lattice edges;
       lattice_angles=[90,90,90];
       % it should be lattice basis used to calculate brag peaks in a
       % reciprocal lattice; 
       is_fcc  = true;
    end
    
    methods
        function this=sample(varargin)
         % the constructor for crystal lattice
         % usage:
         % >>rez=crystal(lattice_parameters,cell_angles,is_fcc)
         % where:
         % lattice_parameters -- tree element vector of direct lattice cell
         %                                parameters (in Angstoms)
         % cell_angles           -- three element vector of direct lattice
         %                               angles between the cell vectors'
          
         % first parameter
            if nargin >= 1               
                if numel(varargin{1}) ~= 3
                    error('SAMPLE:constructor','first parameter, if present have to be vector of three numbers repesenting direct lattice edges');
                else
                    this.lattice_param= varargin{1};
                    if size(this.lattice_param,1)==3
                        this.lattice_param=this.lattice_param';
                    end
                end
            end
        % second parameter;
           if nargin >= 2
                if numel(varargin{2}) ~= 3
                    error('SAMPLE:constructor',' second parameter, if present have to be vector of three numbers repesenting angles between lattice edges');
                else
                    this.lattice_angles= varargin{2};
                    if size(this.lattice_angles,1)==3
                        this.lattice_angles=this.lattice_angles';
                    end
                end
               
           end
           % is FCC
            if nargin >= 3
                this.is_fcc = varargin{3};
            end
           % check lattice paraemeters;
        if max(this.lattice_angles)>=180 || min(this.lattice_angles)<=0
            error('SAMPLE:constructor','Wrong lattice angles: Lattice angles have to be within 0-180 range');  
        end
        if min(this.lattice_param)<= 0
            error('SAMPLE:constructor',' Lattice parameters have to be positive');              
        end
        
  
        end
    end
    
end

