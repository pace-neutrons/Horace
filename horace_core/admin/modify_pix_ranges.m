function [range_stored,minmax]=modify_pix_ranges(filenames)
% Helper function to update pixel ranges stored in old binary sqw files 
% (version below 3.2 stored by Horace 3.5 and earlier)
% to the values, used by Horace 3.6 and later.
%
% The file format is upgraderd from version 3.1 or 2.0 into version 3.3
% version 3.2 is not currently upgradable
%
% Input:
% filenames -- filename or list of filenames, describing full path to
%              binary sqw files to change
%
% Result:
% The file format of the provided files is updated to version 3.3.
% The pixel ranges of the input sqw files are calculated and stored with
% old files in-place.
%
loaders = get_loaders(filenames);
n_inputs = numel(loaders);
%
for i=1:n_inputs
    if ~loaders{i}.sqw_type
        error('SQW_FILE_IO:invalid_argument',...
            'read_horace: File %s contans dnd information but only sqw file requested',...
            fullfile(loaders{i}.filepath,loaders{i}.filename));
    end
end
hc = hor_config;
dts = hc.get_data_to_store();
clob = onCleanup(@()set(hc,dts));
log_level = hc.log_level;
hc.pixel_page_size = hc.mem_chunk_size*9*4;

for i=1:n_inputs
    ld = loaders{i};
    if strcmpi(ld.file_version,'-v3.3')
        if log_level>0
            fprintf(' file %s is already recent version file\n',ld.filename);
        end
        continue
    end
    stor_obj = ld.get_sqw('pixel_page_size',hc.pixel_page_size);
    updater = faccess_sqw_v3_3();
    updater = updater.init(stor_obj);
    
    updater= updater.set_file_to_update(fullfile(ld.filepath,ld.filename));
    updater.put_sqw('-update');
    
%     range_stored = pix.pix_range;
%     minmax = [min(pix.coordinates,[],2),max(pix.coordinates,[],2)]';
%     while pix.has_more
%         [n_page,tot_page_num]=pix.advance;
%         if log_level>0
%             fprintf('*** Processing page: #%d/of#%d\n',...
%                 n_page,tot_page_num);
%         end
%         minmax_pg = [min(pix.coordinates,[],2),max(pix.coordinates,[],2)]';
%         minmax = [min([minmax(1,:);minmax_pg(1,:)],[],1);...
%             max([minmax(2,:);minmax_pg(2,:)],[],1)];
%     end
%     pix.delete();
%     if any(any(abs(range_stored -minmax)>1.e-7))
%         file_name= fullfile(loaders{i}.filepath,loaders{i}.filename);
%         fprintf('*** Incorrect pix range for file %s. modifying\n',...
%             file_name);
%         fprintf('*** Old min: [%6.3g %6.3g %6.3g %6.3g]\n',range_stored(1,:));
%         fprintf('    New min: [%6.3g %6.3g %6.3g %6.3g]\n',minmax(1,:));
%         fprintf('*** Old max: [%6.3g %6.3g %6.3g %6.3g]\n',range_stored(2,:));
%         fprintf('    New max: [%6.3g %6.3g %6.3g %6.3g]\n',minmax(2,:));
%         fprintf('******************************************\n');
%         
%         pix_range_pos = loaders{i}.get_pix_range_pos();
%         change_pix_range(file_name,pix_range_pos,minmax );
%     end
    
end
%
function change_img_range(filename,pix_pos,img_range)
fh = fopen(filename,'rb+');
if fh<1
    error(' Can not open file %s',filename);
else
    clob = onCleanup(@()fclose(fh));
end
fseek(fh,pix_pos,'bof');
[mess,res] = ferror(fh);
if res ~= 0
    error('SQW_BINILE_COMMON:io_error',...
        'Can not move to the urange start position, Reason: %s',mess);
end
data_form = struct();
data_form.pix_range = single([2,4]);
ser = sqw_serializer();
pix_range_wr = struct();
pix_range_wr.pix_range = img_range;
bytes = ser.serialize(pix_range_wr,data_form);
fwrite(fh,bytes);

