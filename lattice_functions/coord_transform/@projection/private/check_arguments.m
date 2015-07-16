function args = check_arguments(fieldName,varargin)
% function verifies if the arguments, assigned to the class are allowed and
% have correct format
%


allFields = {'u','v','w','type','uoffset','lab','lab1','lab2','lab3','lab4'};
vectors3D ={'u','v','w','type'};
vectors4D ={'uoffset','lab'};

if ~any(ismember(allFields,fieldName))
    error('PROJ:invalid_argument','The field %s does not recognized',fieldName);    
end

% check u,v,w,type
if any(ismember(vectors3D,fieldName))
    if numel(varargin{1}==3)
        if(size(varargin{1},2)==3)
            varargin{1} = varargin{1}';
        end
    elseif fieldName =='w'
        if ~isempty(varargin{1})
            error('PROJ:invalid_argument',' vector w should be either empty or a 3-vector')
        end
    else
        error('PROJ:invalid_argument','vector %s should be a 3-vector',fieldName);
    end
    
end

% check uoffset, lab
if any(ismember(vectors4D,fieldName))
    if(numel(varargin) ~= 4)
        error('PROJ:invalid_argument',' field %s should have 4 components',fieldName);
    end
    if strcmp(fieldName,'uoffset')
        if(size(varargin{1},2)==4)
             varargin{1} = varargin{1}';
        end
    end
end

args = varargin;    
