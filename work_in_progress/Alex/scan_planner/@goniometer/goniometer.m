classdef goniometer
% class represents goniometer of an inelascic instrument    
    properties(GetAccess='public', SetAccess='private') 
        % goniopmeter and rotation angles in radian
      
        psi=0;      %     Angle of u w.r.t. ki (rad)
        dpsi=0;    %     Correction to psi (rad)
        omega=0; %     Angle of axis of small goniometer arc w.r.t. notional u
        gl=0;        %    Large goniometer arc angle (rad)
        gs=0;       %     Small goniometer arc angle (rad)
    end
    properties(GetAccess='private',SetAccess='private')
                ang2rad=pi/180;
    end
    methods
        function this=goniometer(varargin)
% usage: 
%>>var=goniometer(psi,dpsi,omega,gl,gs)
%   where
%   psi         Angle of u w.r.t. ki (deg)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (deg)
%   gl          Large goniometer arc angle ((deg)
%   gs          Small goniometer arc angle ((deg)      
% 
        this = reset(this,varargin{:});
        end
%        
        function this=set_psi(this,psi_new)
        % methods sets 
             this.psi=this.ang2rad*psi_new;
        end
        function this=reset(this,varargin)
          
%  each variable is optional; if not present default is used (0)
           if nargin>=2;  this.psi      = varargin{1}*this.ang2rad;
           else
                               this.psi       = 0;
           end
           if nargin>=3;  this.dpsi    = varargin{2}*this.ang2rad;
           else
                               this.dpsi     = 0;
           end
           if nargin>=4;  this.omega = varargin{3}*this.ang2rad;
           else
                               this.omega = 0;
           end
           if nargin>=5;  this.gl        = varargin{4}*this.ang2rad;
           else
                               this.gl        = 0;
           end
           if nargin>=6;  this.gs       = varargin{5}*this.ang2rad;
           else
                               this.gs      = 0;
           end          

        end
    end
    
    
end

