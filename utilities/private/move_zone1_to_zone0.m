function zone_filenames_list=move_zone1_to_zone0(param)

mpi_obj=MPI_State.instance();
is_deployed = mpi_obj.is_deployed;
n_zone = param.n_zone;
n_zones =param.n_tot_zones;

try
    % Estimate the number of pixels in the cut
    if is_deployed
        add_mess = sprintf('Evaluating zone [%d,%d,%d]. Zone:  N%d out of %d',...
            param.zone1_center,n_zone,n_zones);
        mpi_obj.do_logging(n_zone,n_zones,0,add_mess);
    end
    
    if exist(param.data_source,'file')~=2
        error('Source file %s does not exist',param.data_source);
    end
    cut_range = param.cut_ranges;
    %integrated = cellfun(@(x)(isinf(x(1))||isinf(x(2))),cut_range);
    %cut_range = cut_range(~integrated);
    cut_ranges = cellfun(@(x)[x(1),x(end)],cut_range(1:end-1),'UniformOutput',false);
    ei_range = cut_range{end};
    cut_ranges{end+1} = [ei_range(1),0,ei_range(end)];
    ei_range  = cut_ranges{end};
    
    info_obj   = cut_sqw(param.data_source,param.proj,cut_ranges{:},'-nopix');
    
    [n_ranges,e_ranges,zone_filenames_list]=find_subzones(info_obj,ei_range,param.zone_id);
    log_level = get(hor_config,'log_level');
    if log_level>0
        fprintf('Divided zone [%d,%d,%d] into %d part(s) \n',...
            param.zone1_center,n_ranges);
    end
    if is_deployed
        add_mess = sprintf('Divided zone  [%d,%d,%d] into %d parts, Processing part 1',param.zone1_center,n_ranges);
        mpi_obj.do_logging(n_zone,n_zones,0,add_mess);
    end
    
    
    for i=1:n_ranges
        if log_level>0
            fprintf('Processing zone part #%d out of %d\n',i,n_ranges);
        end
        sectioncut=cut_sqw(param.data_source,param.proj,...
            param.cut_ranges{1:end-1},e_ranges(:,i)');
        if n_ranges>1
            sectioncut=cut_sqw(sectioncut,param.proj,...
                param.cut_ranges{1:end-1},e_ranges(:,i)');
        end
        
        if ~isempty(sectioncut.data.pix)
            %Get the permutation of the axes. There are 24 different ways
            %of doing this for the general case, so need to work out how to
            %do it elegantly!
            wtmp=calculate_coord_change(param.zone1_center,param.zone0_center,sectioncut);
            save(wtmp,fullfile(param.rez_location,zone_filenames_list{i}));
        else
            zone_filenames_list{i} = '';
        end
        if is_deployed
            mpi_obj.do_logging(i,n_ranges,[],...
                sprintf('zone [%d,%d,%d] #%d out of %d : Processing parts.',...
                param.zone1_center,n_zone,n_zones));
        end
    end
catch ME
    if strcmpi(ME.identifier,'MESSAGE_FRAMEWORK:cancelled') %just  die
        rethrow(ME);
    end
    %Ensure we don't say a zone is ok when it is not
    zone_c0 = param.zone1_center;
    fprintf('Skipping zone: [%d,%d,%d]. Reason: %s\n',zone_c0(1),...
        zone_c0(2),zone_c0(3),ME.message);
    zone_filenames_list = {};
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