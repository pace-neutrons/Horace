function ok=move_zone1_to_zone0(param)

try
    %We use try/catch in case we get failure with any of these commands
    sectioncut=cut_sqw(param.data_source,param.proj,...
        param.qh_range,param.qk_range,param.ql_range,param.e_range);
    %pos_coords_list=sectioncut.data.pix([1:3],:);%in inverse Ang
    %At this point we check if there were no data in this BZ:
    if ~isempty(sectioncut.data.pix)
        %Get the permutation of the axes. There are 24 different ways
        %of doing this for the general case, so need to work out how to
        %do it elegantly!
        wtmp=calculate_coord_change(param.zone1_center,param.zone0_center,sectioncut);
        save(wtmp,param.zone_fname);
        ok = true;
    else
        ok = false;
    end
catch ME
    %Ensure we don't say a zone is ok when it is not
    zone_c0 = param.zone1_center;
    fprintf('Skipping zone: [%d,%d%,%d]. Reason: %s\n',zone_c0(1),...
        zone_c0(2),zone_c0(3),ME.message);
    ok = false;
end
