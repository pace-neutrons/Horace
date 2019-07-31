function clean_temporary_directory (opt)
% Deletes files from temp area which have one of various ISIS file extensions
%
%   >> clean_temporary_directory
%
%   >> clean_temporary_directory ('-all')   % delete raw and sav files too
%
% Author: T.G.Perring

ext={'sqw','d0d','d1d','d2d','d3d','d4d',...
    'tmp','dat','map','msk','cut','slc','spe','par','phx'};

if nargin==1
    if ischar(opt) && size(opt,1)==1 && size(opt,2)>1 && strncmpi(opt,'-all',numel(opt))
        ext=[ext,{'raw','sav'}];
    else
        error('Unrecognised option')
    end
end

ext=[ext,upper(ext)];   % add upper case extensions to the list

for i=1:numel(ext)
    files=dir(fullfile(tempdir,['*.',ext{i}]));
    for j=1:numel(files)
        if ~files(j).isdir
            nam=fullfile(tempdir,files(j).name);
            try
                delete(nam)
            catch
                disp(['Unable to delete: ',nam])
            end
        end
    end
end
