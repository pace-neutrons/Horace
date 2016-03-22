function zone_filenames_list=move_zone1_to_zone0(param)

mpi_obj=MPI_State.instance();
is_deployed = mpi_obj.is_deployed;
cut_par=param.cut_transf;
n_zone = param.n_zone;
n_zones =param.n_tot_zones;

try
    % Estimate the number of pixels in the cut
    if is_deployed
        add_mess = sprintf('Processing zone ID#%d Its: [%d,%d,%d]'  ,...
            cut_par.zone_id,cut_par.zone_center);
        mpi_obj.do_logging(n_zone,n_zones,0,add_mess);
    end
    
    if exist(param.data_source,'file')~=2
        error('Source file %s does not exist',param.data_source);
    end
    cut_range = cut_par.cut_range;
    % get integration ranges of the cut to estimate number of pixels in
    % zone to transform.
    % TODO: Should be better way of doing this useing DND object or
    % projection methods
    cut_ranges = cellfun(@(x)[x(1),x(end)],cut_range(1:end-1),'UniformOutput',false);
    ei_range = cut_range{end};
    cut_ranges{end+1} = [ei_range(1),0,ei_range(end)];
    ei_range  = cut_ranges{end};
    
    info_obj   = cut_sqw(param.data_source,param.proj,cut_ranges{:},'-nopix');
    %
    % how many subzones zone has to be split to fit memory
    [n_ranges,e_ranges,zone_filenames_list]=find_subzones(info_obj,ei_range,cut_par.zone_id);
    log_level = get(hor_config,'log_level');
    if log_level>0
        fprintf('Divided zone [%d,%d,%d] into %d part(s) \n',...
            cut_par.zone_center,n_ranges);
    end
    if is_deployed
        add_mess = sprintf('Divided zone  [%d,%d,%d] into %d chunks, Starting chunk #1',cut_par.zone_center,n_ranges);
        mpi_obj.do_logging(n_zone,n_zones,0,add_mess);
    end
    
    
    for i=1:n_ranges
        if log_level>0
            fprintf('Processing zone part #%d out of %d\n',i,n_ranges);
        end
        sect_range = {cut_par.cut_range{1:end-1},e_ranges(:,i)'};
        sectioncut=cut_sqw(param.data_source,param.proj,sect_range{:});
        if n_ranges>1 % rebin within total binning range rather then the
            % partial done by cut above
            sectioncut=cut_sqw(sectioncut,param.proj,...
                cut_par.cut_range{1:end-1},ei_range);
        end
        
        
        if ~isempty(sectioncut.data.pix)
            % if correction function is defined, apply correction function
            % to the object before transforming its coordinates
            if ~isempty(cut_par.correct_fun)
                sectioncut = cut_par.correct_fun(sectioncut);
            end
            % transform coordinates of this zone into coordinates of target
            % zone
            wtmp=transform_coordinates(sectioncut,cut_par.transf_matrix,...
                cut_par.shift,(n_zone-1)*sectioncut.main_header.nfiles);
            % transform cut headers to combine them properly
            wtmp = trahsform_headers(wtmp,cut_par.zone_id,cut_par.zone_center,...
                i,n_ranges);
            save(wtmp,fullfile(param.rez_location,zone_filenames_list{i}));
        else
            zone_filenames_list{i} = '';
        end
        if is_deployed
            mpi_obj.do_logging(i,n_ranges,[],...
                sprintf('zone [%d,%d,%d] #%d out of %d : Processing chunks.',...
                cut_par.zone_center,n_zone,n_zones));
        end
    end
catch ME
    if strcmpi(ME.identifier,'MESSAGE_FRAMEWORK:cancelled') %just  die
        rethrow(ME);
    end
    %Ensure we don't say a zone is ok when it is not
    zone_c0 = cut_par.zone_center;
    fprintf('Skipping zone: [%d,%d,%d]. Reason: %s\n',zone_c0(1),...
        zone_c0(2),zone_c0(3),ME.message);
    zone_filenames_list = {};
end
end
%
function  cut_part = trahsform_headers(cut_part,zone_id,zone_center,...
    n_cur_chunk,num_chunks)
% transform headers to store information about zone the header has been cut
% out and the chunk the zone has been divided into

headers = cut_part.header;
file_id = sprintf('_zoneID#%d_center[%d,%d,%d]',zone_id,zone_center(1),...
    zone_center(2),zone_center(3));
n_headers = numel(headers);
chunk_id = sprintf('pixBase%dZoneID%dchunk%d#%d',n_headers,zone_id,...
           n_cur_chunk,num_chunks);


    function hd = change_header(hd)
        hd.filename = [hd.filename,file_id];
        hd.filepath = chunk_id;
    end    

headers = cellfun(@(x)change_header(x),headers,'UniformOutput',false);
cut_part.header = headers;
end

function [n_ranges,eranges,zone_fnames]=find_subzones(info_obj,erange,zone_id)
% separate total zone into range of subzones containing sufficiently large
% number of pixes, but small enough to fit the availible memory
%
zone_fname_fun = @(id,n_block)(sprintf('HoracePartialZoneN%d_file_partN%d.tmp',id,n_block));

e_axis = info_obj.p{1};
npix   = info_obj.npix;

tot_pix = sum(npix);
% specify reasonuble number of pixels, to be present in a single subzone
npix_in_range = 3*get(hor_config,'mem_chunk_size');


if 2*npix_in_range > tot_pix
    n_ranges   = 1;
    eranges    = erange';
    zone_fnames= {zone_fname_fun(zone_id,0)};
    return
end
% how many ranges we want to split our zone into
n_ranges = ceil(tot_pix/npix_in_range);
npix_in_range = tot_pix/n_ranges;
limits = npix_in_range*ones(n_ranges,1);
limits = cumsum(limits);
npix_sum = cumsum(npix);
%
eranges = zeros(3,n_ranges);
zone_fnames= cell(n_ranges,1);
%
pix_in_block_prev = false(numel(npix_sum ),1);
for i=1:n_ranges
    pix_in_block = npix_sum<=limits(i);
    e_block = e_axis(pix_in_block &(~pix_in_block_prev));
    pix_in_block_prev = pix_in_block;
    eranges(1,i) = e_block(1);
    eranges(3,i) = e_block(end);
    eranges(2,i) = sum(e_block(2:end)-e_block(1:end-1))/numel(e_block);
    zone_fnames{i} = zone_fname_fun(zone_id,i);
end
% just in case:
eranges(1,1)        = erange(1);
eranges(3,n_ranges) = erange(3);
% make max energy range of previous zone coinside with min range of the
% folowing one
for i=2:n_ranges
    eranges(1,i) = eranges(3,i-1)+2*eps(eranges(3,i-1));
end
end

function wout=transform_coordinates(w1,transf_matrix,shifts,pixid_shift)
% Routine applies speficified symmetry operation, to the pixels of input
% object w1 The symmetry operation is determined bny the transformation
% matrix (transf_matrix) and shifn (shift).
%
% pixid_shift contains additional information about pixel's zone.
%             This  informaiton consist of production of the (zone_id-1) and
%             the number of files, contributed into the initial sqw file.
%             zone_id can be recovered by the oppozite operation:
%             zone_is = ceil(new_pix_id/n_contributed_files)
%
%
%Initialise the output:
wout=w1;
%Now we work out how to alter each of the objects:
%
%We must ensure that we look at the coordinates in terms of reciprocal
%lattice units:
u_to_rlu1=w1.data.u_to_rlu(1:3,1:3);
umat1=repmat(w1.data.ulen(1:3)',1,3);
T1=u_to_rlu1./umat1;
T_sym = transf_matrix*T1;


if all(shifts==0)
    coords1=w1.data.pix(1:3,:);
    coords_rlu1=T_sym*coords1;
else
    shifts_in_a = T1\shifts';
    coords_rlu1=T_sym*bsxfun(@plus,w1.data.pix(1:3,:),shifts_in_a);
end
% modify pixel's id to add informaion about zone, pixel came from
if pixid_shift~=0
    wout.data.pix(5,:)= w1.data.pix(5,:)+pixid_shift;
end

%coords2=w2.data.pix([1:3],:);
p1=w1.data.p;
%p2=w2.data.p;

%
%
%This bit is for debug:
%u_to_rlu2=w2.data.u_to_rlu(1:3,1:3);
%umat2=repmat(w2.data.ulen(1:3)',1,3);
%T2=u_to_rlu2./umat2;
%coords_rlu2=T2*coords2;

%Convert coordinates back to inverse Angstroms:
coords_ang=(inv(T1))*coords_rlu1;
%Make the required changes to the p1 cell array:
p1new=p1;
for i=1:3
    ort = zeros(3,1);
    ort(i) = 1;
    new_ort = ort'*transf_matrix; % the result should have unit length by transf
    % matrix definition
    new_axis=arrayfun(@(x,y,z)(new_ort(1)*(x+shifts(1))+...
        new_ort(2)*(y+shifts(2))+...
        new_ort(3)*(z+shifts(3))),...
        p1{1},p1{2},p1{3});
    if new_axis(1)>new_axis(end)
        p1new{i} =  flipud(new_axis);
    else
        p1new{i} = new_axis;
    end
end

%Place the new coords_ang1 and p1 arrays into the output object:
wout.data.pix(1:3,:)=coords_ang;
wout.data.p=p1new;

%Use the internal Horace routines to recalculate intensity/error/npix etc
%arrays:
argi = cell(1,numel(p1new));
wout=cut(wout,argi{:});
end