function hdf5save_recursion(filename,prefix,new,varargin)
% Usage:
%   hdf5save('filename','prefix',new,'name in workspace','name in hdf5 file',...)
%   hdf5save('filename','prefix',new,structure)
% 
%
% Save the given variables in an hdf5 file in the groupe given by the
% prefix. If new is set to one creates a new hdf5 file.
% Can save strings, arrays, and structs.
% If it find a struct it calls its recusively to save the struct, passing
% the struct name as the prefix.

if ~ischar(filename) ;
    error('first argument should be a string giving the path to the hdf5 file to save') ;
end

if ~ischar(prefix) ;
    error('second argument should be a string giving the name of the groupe to save the data in') ;
end

if new~=1 && new~=0 ;
    error('third argument should be 0 or 1: 0 to append data, and 1 to create a new file')
end

nvars=(nargin-3)/2;

if nvars~=floor(nvars) ;
    if nargin==4
        varcell{1}=strtrim(prefix);
        varcell{2}=varargin{1};            
        nvars     = 1;
    else
        error('expecting a name for each variable') ;
    end
else
    varcell=varargin;
end

for i=1:nvars
    name=strtrim(varcell{2*i-1});   
    str =varcell{2*i};
    try 
        names=fieldnames(str);
        for j=1:size(names,1) ;
            if (j~=1 || i~=1)
                new=0 ;
            end
            hdf5save_recursion(filename,[name,'/'],new,names{j},str.(names{j}));
        end       
    catch  % it is not a structure or class       otherwise
       location=strcat('/',prefix,name);
       if new==1 && i==1 ;
                hdf5write(filename,location,str);
       else
                %disp(['location : ',location]);
                hdf5write(filename,location,str,'WriteMode', 'append');
       end
    end

end
 