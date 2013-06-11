function [tmp_file_names,tmp_exist] = gensqw_check_tmp_files(input_data_files,tmp_files_path,urange)
% Method builds the list of the tmp files and check if they exist
%
% Input:
% input_data_files -- list of input data file names which will be used as
%                     the basis for uoutput names
% tmp_files_path   -- the path to place output files
% urange           -- data limits which has to be the same for all existing
%                     tmp files for them to be deemed acceptable


% Make names of intermediate files
tmp_file_names = cell(size(input_data_files));

nfiles   = numel(input_data_files);
tmp_exist=zeros(1,nfiles);

wk_ext  = get(hor_config,'sqw_ext');
for i=1:nfiles
     [spe_path,spe_name]=fileparts(input_data_files{i});
     tmp_file_names{i}=fullfile(tmp_files_path,[spe_name,wk_ext]);
     tmp_exist(i)=exist(tmp_file_names{i},'file');%returns 2 if tmp file exists
     
    if tmp_exist(i)==2
        hinfo=head_sqw(tmp_file_names{i});
        small=1e-5;
        if isfield(hinfo,'data')
            hinfo = hinfo.data;
        end
        urange_tmp=[min(hinfo.p{1}) min(hinfo.p{2}) min(hinfo.p{3}) min(hinfo.p{4}); ...
            max(hinfo.p{1}) max(hinfo.p{2}) max(hinfo.p{3}) max(hinfo.p{4})];
        if ~(all(urange(1,:)<=urange_tmp(1,:)+small) && all(urange(2,:)>=urange_tmp(2,:)-small))
            if(get(hor_config,'horace_info_level') >1)            
                disp(['Existing tmp file ',tmp_file_names{i},' is not consistent with data range required']);
                disp(['It will be overwritten']);                
            end
            tmp_exist(i)=-1;
        else
            if(get(hor_config,'horace_info_level') >1)
                disp('--------------------------------------------------------------------------------')
                disp(['while Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
                disp(['Spe file ',num2str(i),' of ',num2str(nfiles),' already has a coresponding tmp file'])
                disp('');    
            end
        end
    end
     
end
