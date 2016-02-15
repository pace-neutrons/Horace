function zone_filenames_list=move_zone1_to_zone0(param)

try
    % Crudely estimate the number of pixels in the cut (not always aligned but we
    % let's ise it as a guess)
    if exist(param.data_source,'file')~=2
        error('Source file %s does not exist',param.data_source);
    end
    info_obj   = cut_dnd(param.data_source,...
        [param.qh_range(1),param.qh_range(3)],...
        [param.qk_range(1),param.qk_range(3)],...
        [param.ql_range(1),param.ql_range(3)],...        
        [param.e_range(1),0,param.e_range(3)]);
    [n_ranges,e_ranges,zone_filenames_list]=find_subzones(info_obj,param.e_range,param.zone_id);
    log_level = get(hor_config,'log_level');
    if log_level>0
        fprintf('Divided zone [%d,%d,%d] into %d part(s) \n',...
        param.zone1_center,n_ranges);
    end
    
    for i=1:n_ranges
        if log_level>0        
            fprintf('Processing zone part #%d out of %d\n',i,n_ranges);
        end
        sectioncut=cut_sqw(param.data_source,param.proj,...
            param.qh_range,param.qk_range,param.ql_range,e_ranges(:,i)');
        if n_ranges>1
            sectioncut=cut_sqw(sectioncut,param.proj,...
                param.qh_range,param.qk_range,param.ql_range,param.e_range);            
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
    end
catch ME
    %Ensure we don't say a zone is ok when it is not
    zone_c0 = param.zone1_center;
    fprintf('Skipping zone: [%d,%d%,%d]. Reason: %s\n',zone_c0(1),...
        zone_c0(2),zone_c0(3),ME.message);
    zone_filenames_list = {};
end

function [n_ranges,eranges,zone_fnames]=find_subzones(info_obj,erange,zone_id)
% separate total zone into range of subzones containing sufficiently large
% number of pixes
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