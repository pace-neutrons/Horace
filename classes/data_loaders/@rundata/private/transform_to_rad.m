function varargout = transform_to_rad(varargin)
% function thransforms input values which are known to have units of degree
% into radians
% varargin can be either a structure with different fields
% or the cell array of "key"-"value" pairs
%
% Only the know fields of the structure or values for the known keys are
% modified
% known names are:
% 'psi','omega','dpsi','gl','gs' 
%
%

known_angles={'psi','omega','dpsi','gl','gs'};
deg2rad=pi/180;

if nargin==1 && isstruct(varargin{1}) % have input sructure;
    out=varargin{1};
    flname = fieldnames(out);
    are_angles=ismember(flname,known_angles);    
    for i=1:numel(flname)
        if are_angles(i)
            out.(flname{i})=out.(flname{i})*deg2rad;
        end
    end
    varargout{1}=out;
else
    arg = varargin{1};
    the_fields={arg{2,:}};
    are_angles=ismember(the_fields,known_angles);
    varargout= {arg{1,:}};
    for i=1:numel(varargout)
        if are_angles(i)
            varargout{i}=varargout{i}*deg2rad;
        end
    end    
    varargout={varargout};

end
% 
% function val=to_rad(num,is_angle)
% val = num;
% if is_angle
%     val=val*pi/180;
% end