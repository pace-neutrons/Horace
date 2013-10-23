function clean_temporary_area
% Deletes files from temp area which have one of various ISIS file extensions

ext={'sqw','tmp','map','msk','cut','slc','spe','par','phx',...
     'SQW','TMP','MAP','MSK','CUT','SLC','SPE','PAR','PHX'};

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
