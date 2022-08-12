function [nxspe_file_names,psi] = gen_bm_gen_sqw_data(dataSize,dataSet)
%GEN_GEN_SQW_DATA Summary of this function goes here
%   Detailed explanation goes here
pths = horace_paths;
common_data = fullfile(pths.bm,'common_data');
par_file = fullfile(common_data,'4to1_124.par');

switch dataSet
    case 'small'
        psi = 0:8:90;
    case 'medium'
        psi = 0:4:90;
    case 'large'
        psi = 0:2:90;
    otherwise
        try
            psi = dataSet;
        catch
            error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                ,"dataSet is the number of nxspe files used to generate an" + ...
                "sqw object : must be small, medium, large (char type) or " + ...
                "and array (0:X:Y)")
        end
end

efix = 787;
folder_pth = fullfile(pths.bm,'bm_gen_sqw');
spe_file_names = cell(1,numel(psi));
nxspe_file_names = cell(1,numel(psi));

switch dataSize
    case 'small'
        en = 0:16:efix;
%         par_file = [0 16 efix];
    case 'medium'
        en = 0:8:efix;
%         par_file = [0 8 efix;0 8 efix;0 8 efix];
    case 'large'
        en = 0:4:efix;
%         par_file = [0 4 efix;0 4 efix;0 4 efix];
    otherwise
        try
            en = dataSize;
%             par_file = en;
        catch
            error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                ,"dataSize is the size of the nxspe files used to generate an" + ...
                "sqw object : must be small, medium, large (char type) or " + ...
                "represnet the size of the ebins (an array of type: 0:X:Y)")
        end
end

% lattice = convert_old_input_to_lat(alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
% lat = oriented_lattice(alatt,angdeg,psi,u,v,omega,dpsi,gl,gs);
% disp(lattice)
% par_file = build_det_from_q_range(par_file,efix,lattice);


for i=1:numel(psi)
    spe_file_names{i}=fullfile(['bm_gen_sqw',num2str(i),'.spe']);
    nxspe_file_names{i}=fullfile(['bm_gen_sqw',num2str(i),'.nxspe']);
    if ~is_file(spe_file_names{i})
        spe_data = dummy_spe(36864,en,spe_file_names{i},folder_pth);
        gen_nxspe(spe_data.S,spe_data.ERR,spe_data.en,par_file,...
            nxspe_file_names{i},787)
        delete(spe_file_names{i})
    end
end

end

