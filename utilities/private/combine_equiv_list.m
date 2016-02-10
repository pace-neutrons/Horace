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
if ~(numel(step)==3 || numel(step)==1)
    error('COMBINE_EQUIV_LIST:invalid_argument','step variable should have 1 or 3 components')
end

if isa(step,'q_step')
    if numel(step)==1
        step=[step,step,step];
    end
else % list of cut ranges provided
    if numel(step)==1
        step=[q_step(step),q_step(step),q_step(step)];
    else
        step=[q_step(step(1)),q_step(step(2)),q_step(step(3))];
    end
end

range=cell(numel(zonelist),4);
for i=1:numel(zonelist)
    range{i,1}=[zonelist{i}(1)+step(1).q_min,step(1).dq,zonelist{i}(1)+step(1).q_max];
    range{i,2}=[zonelist{i}(2)+step(2).q_min,step(2).dq,zonelist{i}(2)+step(2).q_max];
    range{i,3}=[zonelist{i}(3)+step(3).q_min,step(3).dq,zonelist{i}(3)+step(3).q_max];
    range{i,4}=erange;
end

%Get directory in which the data live. This is where we will save temporary
%files.
sourcedir=fileparts(data_source);
%Generate file names for each transformed zone
zone_fnames_list = cell(numel(zonelist),1);
for i=1:numel(zonelist)
    zone_fnames_list{i} = fullfile(sourcedir,['HoraceTempSymInternal',num2str(i),'.sqw']);
end
% add these files to cleanup to remove them in case of errors or at the end
% of calculations:
    function clear_tmp_file(name)
        if exist(name,'file')==2
            delete(name);
        end
    end
clobj1 = onCleanup(@()cellfun(@(fn)clear_tmp_file(fn),zone_fnames_list));

%==========================================================================
%First create all of the 4-dimensional cuts from the data that we need. We
%will save them to temporary files with silly names, which must be deleted
%when this function has finished running.

disp('');
disp('----------------------------------------------------------------');
disp('                    Starting symmetrisation                     ');
disp('----------------------------------------------------------------');
disp('');
disp('Taking cuts from equivalent zones, converting coordinats        ');
disp(' and saving results to temporary files                          ');
disp('');
disp('----------------------------------------------------------------');
disp('');

%Note -  we have to make a check here to ensure that we do not already have
%some files called horacetempsyminternal... otherwise we could end up reading the
%wrong data... delete any pre-existing files of this name.

%Suppress output messages from Horace, otherwise the screen is flooded with
%lots of useless info...
% Turn off horace_info output, but save for automatic cleanup on exit or cntl-C (TGP 30/11/13)
%info_level = get(hor_config,'horace_info_level');
%cleanup_obj=onCleanup(@()set(hor_config,'horace_info_level',info_level));
%set(hor_config,'horace_info_level',-1);


%First we work out which element of zonelist corresponds to pos:
ind = -1;
for i=1:numel(zonelist)
    if isequal(zonelist{i},pos)
        ind=i;
    end
end
if ind == -1 % extend zone list to the basic sone
    zonelist{end+1} = pos;
    range{end+1}=range{end};
    ind = numel(zonelist);
end
%Now we must work out how all of the data relate to this. The pix array
%give h,k,l in inverse Angstroms, so we can do relatively simple matrix
%operations on them to convert to our chosen BZ:
root_zone=cut_sqw(data_source,proj,range{ind,1},range{ind,2},range{ind,3},range{ind,4});
if exist(zone_fnames_list{ind},'file')~=2
    save(root_zone,zone_fnames_list{ind});
end
%pos_coords=poscut.data.pix([1:3],:);%in inverse Ang



%Create new temporary files for all of the required zones. If there are no
%data in the specified zone we must be able to continue without getting an
%error:
zoneok= true(numel(zonelist),1);
zoneok(ind) = true;
for i=1:numel(zonelist)
    if i==ind
        continue;
    end
    try
        %We use try/catch in case we get failure with any of these commands
        sectioncut=cut_sqw(data_source,proj,range{i,1},range{i,2},range{i,3},range{i,4});
        %pos_coords_list=sectioncut.data.pix([1:3],:);%in inverse Ang
        %At this point we check if there were no data in this BZ:
        if ~isempty(sectioncut.data.pix)
            %Get the permutation of the axes. There are 24 different ways
            %of doing this for the general case, so need to work out how to
            %do it elegantly!
            wtmp=calculate_coord_change(zonelist{i},pos,sectioncut,root_zone);
            save(wtmp,zone_fnames_list{i});
            
            zoneok(i) = true;
        else
            zoneok(i) = false;
        end
    catch ME
        %Ensure we don't say a zone is ok when it is not
        fprintf('Skipping zone: [%d,%d%,d]. Reason: %s\n',zonelist{i}(1),...
            zonelist{i}(2),zonelist{i}(3),ME.message);
        zoneok(ind) = false;
    end
end
zone_fnames_list = zone_fnames_list(zoneok);
%==================================

%We need to work out how each of the Brillouin zones in zonelist relate to
%the pos argument. This will then tell us how we must transform the
%co-ordinates in the pix arrays.
disp('');
disp('Combining data on disk');
disp('');
disp('----------------------------------------------------------------');
disp('');

%Finally save the correct output to disk:
write_nsqw_to_sqw (root_zone, zone_fnames_list, outfile,'allow_equal_headers');

if nargout>0
    wout = read_sqw(outfile);
    varargout{1}=wout;
end

disp('');
disp('----------------------------------------------------------------');
disp('                    Symmetrisation finished                     ');
disp('----------------------------------------------------------------');
disp('');
end

