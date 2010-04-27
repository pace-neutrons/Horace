function   this = combine_multiple_nxs_files(this,listOne_spe_fileNames)
% function pulls out the data from multiple hdf5 nxs files and writes these
% data into single sqw file;
%
%
% $Revision$ ($Date$)
%

% here we construct space to accumulate the information about the headers
% of all contributing data files. 
this = create_headers_group(this);
%
nfiles =numel(listOne_spe_fileNames); 
disp(' ')
disp('Reading and accumulating binning information of input file(s)...')
mess_completion(nfiles,5,0.1);   % initialise completion message reporting

% start processing pixels layout
this.spe_headers_list=cell(1,numel(listOne_spe_fileNames));


this.spe_headers_list{1}=one_sqw(listOne_spe_fileNames{1},'-nonew');     
head     = this.spe_headers_list{1}.read_header();
detectors= this.spe_headers_list{1}.read_detectors();
% write the component header into the resulting file
this  = this.write_component_header(head);
this  = this.write_detectors(detectors);

urange  = head.urange;

for i=2:nfiles 
    % it should be test for headers consistency here;
    this.spe_headers_list{i}=one_sqw(listOne_spe_fileNames{i},'-nonew');
    head  = this.spe_headers_list{i}.read_header();
    
    % check detectors consistency:
    if ~strcmp(this.det_filename,this.spe_headers_list{i}.det_filename)||...
        (~strcmp(this.det_filepath,this.spe_headers_list{i}.det_filepath))
        % if filenames are different, we have to look deeper;
        difr = this.spe_headers_list{i}.difr(detectors);
        if any(abs(difr)>1.e-3)
            error('HORACE:hdf_tools','detectors from first (%s) and %d-th (%s) datafiles are different',...
                  this.filename,i,this.spe_headers_list{i}.filename);
        end
    end
    
    % write the component header into the resulting file
    this  = this.write_component_header(head);
    
    urange(1,:) = min(urange(1,:),head.urange(1,:));
    urange(2,:) = max(urange(2,:),head.urange(2,:));   
end
% *** > debug -- it is unclear what to do with these and where are they all defined:
head.iax=[0,0,0,0];
head.iint=zeros(2,size(head.iax,2));
% *** >
head.urange  = urange;

header=build_sqwn_header(this.sqw_file_header,nfiles,head);
header.filename= this.filename;
header.filepath= this.filepath;

this.write_spe_header(header);

%this.urange             =this.spe_headers_list{1}.urange;

dataI      = read_signal(this.spe_headers_list{1});     
s_accum    = (dataI.s).*(dataI.npix);
e_accum    = (dataI.e).*(dataI.npix).^2;
npix_accum = dataI.npix;
for i=2:nfiles 
        dataI     = this.spe_headers_list{i}.read_signal();

        s_accum   = s_accum + (dataI.s).*(dataI.npix);
        e_accum   = e_accum + (dataI.e).*(dataI.npix).^2;
        npix_accum= npix_accum + dataI.npix;

       
        mess_completion(i)        
end
s_accum = s_accum ./ npix_accum;
e_accum = e_accum ./ npix_accum.^2;
nopix=(npix_accum==0);
s_accum(nopix)=0;
e_accum(nopix)=0;

data.s    = s_accum;
data.e    = e_accum;
data.npix = npix_accum;
clear s_accum e_accum nopix;


this = build_pixel_dataspace_layout(this,npix_accum);


% write signal together with the header data (headers were written earlier)
%this=write_extended_header(this,data);
this = write_signal(this,data);

mess_completion
clear data

disp('input file have been preprocessed; now combining them together ...')
disp(' ')
mess_completion(nfiles,5,0.1);   % initialise completion message reporting


dataI  = read(this.spe_headers_list{1},'-pix');
chunks = find(dataI.npix); 
dataI.pix(5,:)=1;

this   = write_pixel_chunks(this,dataI.pix,chunks,dataI.npix);

ncells = numel(dataI.npix);
% recalculate the pixels locations considerend the pars, which are occupied
% by the pixels just written to hdd. 
this.pixel_dataspace_layout=this.pixel_dataspace_layout(1:ncells)+reshape(dataI.npix,1,ncells);  
for i=2:nfiles
        dataI         = read(this.spe_headers_list{i},'-pix');
        dataI.pix(5,:)= i;
        
        chunks= find(dataI.npix); 
        this  = write_pixel_chunks(this,dataI.pix,chunks,dataI.npix);
        ncells = numel(dataI.npix);
        this.pixel_dataspace_layout=this.pixel_dataspace_layout(1:ncells)+reshape(dataI.npix,1,ncells);  

        mess_completion(i)              
end
% recalculate dataspace layout to its initial state for future usage;
this.pixel_dataspace_layout=build_pixel_dataspace_layout(this,npix_accum);

mess_completion
clear npix_accum;
% this will close the nxs files and clearn up the datasets, associated
% with tese files
for i=1:nfiles
        delete(this.spe_headers_list{i});
end







       
