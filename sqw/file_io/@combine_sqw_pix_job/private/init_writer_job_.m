function [fout,data_providers,data_remain,clob] = init_writer_job_(obj,pix_comb_info)
% process job inputs and return initial information for writer job
%
%Returns:
% fout -- initialized handle for opened binary file to write data
% data_providers -- list of the lab nums will be sending data to the writer
%                   job
% data_remain    -- array of logical, indicating if a correspondent data
%                   provider is active (true at the beginning)
% clob           -- clean up object responsible for closing ouptut file at 
%                   the end of operation or in case of an error
 

filename = pix_comb_info.fout_name;
fout = fopen(filename,'rb+');
if fout<=0
    error('COMBINE_PIX_JOB:runtime_error',...
        'Can not open target file %s for writing',filename);
end
clob = onCleanup(@()fcloser_(fout));  %

pix_out_position = pix_comb_info.pix_out_pos;
fseek(fout,pix_out_position,'bof');
check_error_report_fail_(fout,...
    sprintf(['Unable to move to the start of the pixel'...
    ' record to write the target file %s '...
    'to start writing combined pixels'],...
    filename));
% all other labs will send the pixel data to the writer
data_providers = 2:obj.mess_framework.numLabs;
data_remain    = true(size(data_providers ));
