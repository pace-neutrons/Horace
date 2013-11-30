function varargout=combine_equiv_list(data_source,proj,pos,step,erange,outfile,zonelist)
%
% Called by combine_equivalent_zones, combine_equiv_keyword and
% combine_equiv_basic
%
% RAE 30/3/2010

%This is the function we call when we actually want to do the combination
%of a specified list of symmetrically equivalent points

%First we must work out the ranges for each of the zones we're interested
%in. Package these up as another cell array which is n-by-3, where n is the
%number of equivalent zones.

if numel(step)==1
    step=[step,step,step];
end

range=cell(numel(zonelist),4);
for i=1:numel(zonelist)
    range{i,1}=[zonelist{i}(1)-1,step(1),zonelist{i}(1)+1];
    range{i,2}=[zonelist{i}(2)-1,step(2),zonelist{i}(2)+1];
    range{i,3}=[zonelist{i}(3)-1,step(3),zonelist{i}(3)+1];
%     range{i,1}=[zonelist{i}(1)-0.1,step(1),zonelist{i}(1)+0.1];
%     range{i,2}=[zonelist{i}(2)-0.1,step(2),zonelist{i}(2)+0.1];%temporary setup for debug
%     range{i,3}=[zonelist{i}(3)-0.1,step(3),zonelist{i}(3)+0.1];
    range{i,4}=erange;
end

%Get directory in which the data live. This is where we will save temporary
%files.
sourcedir=[fileparts(data_source),'/'];

%==========================================================================
%First create all of the 4-dimensional cuts from the data that we need. We
%will save them to temporary files with silly names, which must be deleted
%when this function has finished running.

disp('');
disp('----------------------------------------------------------------');
disp('                    Starting symmetrisation                     ');
disp('----------------------------------------------------------------');
disp('');
disp('Taking cuts from equivalent zones, and saving to temporary files');
disp('');
disp('----------------------------------------------------------------');
disp('');

%Note -  we have to make a check here to ensure that we do not already have
%some files called horacetempsyminternal... otherwise we could end up reading the
%wrong data... delete any pre-existing files of this name.

%Suppress output messages from Horace, otherwise the screen is flooded with
%lots of useless info...
% Turn off horace_info output, but save for automatic cleanup on exit or cntl-C (TGP 30/11/13)
info_level = get(hor_config,'horace_info_level');
cleanup_obj=onCleanup(@()set(hor_config,'horace_info_level',info_level));
set(hor_config,'horace_info_level',-1);

%Clean up pre-existing temporary files:
for i=1:48
    if exist([sourcedir,'HoraceTempSymInternal',num2str(i),'.sqw'],'file')==2
        delete([sourcedir,'HoraceTempSymInternal',num2str(i),'.sqw']);
    end
end

%Create new temporary files for all of the required zones. If there are no
%data in the specified zone we must be able to continue without getting an
%error:
zoneok=[];
for i=1:numel(zonelist)
    try
        %We use try/catch in case we get failure with any of these commands
        zoneok=[zoneok i];
        sectioncut=cut_sqw(data_source,proj,range{i,1},range{i,2},range{i,3},range{i,4});
        save(sectioncut,[sourcedir,'HoraceTempSymInternal',num2str(i),'.sqw']);
        %now clear from memory:
        clear sectioncut
    catch
        %Ensure we don't say a zone is ok when it is not, but prevent
        %Horace giving an error message
        zoneok(end)=[];
    end    
end

%zoneok=[1:6 8:12];%for debug

%Note that the above is not the most efficient way of doing things, because
%we are going to simply read everything back in again. However for now
%(debug) it is probably for the best.

%==================================

%We need to work out how each of the Brillouin zones in zonelist relate to
%the pos argument. This will then tell us how we must transform the
%co-ordinates in the pix arrays.

%First we work out which element of zonelist corresponds to pos:
for i=1:numel(zonelist)
    if isequal(zonelist{i},pos)
        ind=i;
    end
end


%Now we must work out how all of the data relate to this. The pix array
%give h,k,l in inverse Angstroms, so we can do relatively simple matrix
%operations on them to convert to our chosen BZ:
poscut=cut_sqw([sourcedir,'HoraceTempSymInternal',num2str(ind),'.sqw'],[],[],[],[]);
pos_coords=poscut.data.pix([1:3],:);%in inverse Ang
%

%We have to check that there are actually some data in this set:
if isempty(pos_coords)
    disp('Horace error: the argument pos defines a Brillouin zone in which there are no data');
    for j=1:numel(zonelist)
            delete([sourcedir,'HoraceTempSymInternal',num2str(j),'.sqw']);
    end
    disp('');
    disp('------------------------------');
    disp('   Temporary files deleted    ');
    disp('------------------------------');
    return;
end

disp('');
disp('Calculating mapping between specified Brillouin zones');
disp('');
disp('----------------------------------------------------------------');
disp('');

%We now need to work out the transformation that gets us from pos to each
%element of zonelist
j=1; notempty=[];
for i=zoneok
    if i~=ind
        poscut_list=cut_sqw([sourcedir,'HoraceTempSymInternal',num2str(i),'.sqw'],[],[],[],[]);
        pos_coords_list=poscut_list.data.pix([1:3],:);%in inverse Ang
        %At this point we check if there were no data in this BZ:
        if ~isempty(pos_coords_list)
            %Get the permutation of the axes. There are 24 different ways
            %of doing this for the general case, so need to work out how to
            %do it elegantly!
            wtmp(j)=calculate_coord_change(zonelist{i},pos,poscut_list,poscut);
            j=j+1;
            notempty=[notempty i];
            %Note that we are now holding all of the individual symmetrise
            %objects in memory
        end
    end
end

disp('');
disp('Combining data');
disp('');
disp('----------------------------------------------------------------');
disp('');

%In the final steps we collect together all of the pixel info from all of
%the wtmp objects, and combine them into the original data object poscut.
wout=poscut;
fullpix=wout.data.pix;
for i=1:numel(notempty)
    fullpix=[fullpix wtmp(i).data.pix];
end

%We should not have any repeated pixels, but in case we do, use the unique
%command to get rid of them:
fullpix=unique(fullpix','rows');
fullpix=fullpix';

%We cannot just insert fullpix into wout, because doing so would make the
%sqw object non-self-consistent:
getit=get(wout);
getit.data.pix=fullpix;
getit.data.npix=zeros(size(wout.data.s));
getit.data.npix(1,1,1,1)=(numel(fullpix))/9;
wout=sqw(getit);
%clear getit;

% 
% disp('');
% disp('Saving partial data to disk');
% disp('');
% disp('----------------------------------------------------------------');
% disp('');
% %Save to disk:
% save(wout,[sourcedir,'HoraceTmpInternalMaster.sqw']);
% 
% %Re-read from disk. This sorts out all of the bin information:
% wout=cut_sqw([sourcedir,'HoraceTmpInternalMaster.sqw'],[],[],[],[]);

wout=cut(wout,[],[],[],[]);

disp('');
disp('Saving final output to disk');
disp('');
disp('----------------------------------------------------------------');
disp('');
%Finally save the correct output to disk, and clear up intermediate files:
save(wout,outfile);
%delete([sourcedir,'HoraceTmpInternalMaster.sqw']);

varargout{1}=wout;

disp('');
disp('----------------------------------------------------------------');
disp('                    Symmetrisation finished                     ');
disp('----------------------------------------------------------------');
disp('');

