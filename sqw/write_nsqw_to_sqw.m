function write_nsqw_to_sqw (infiles, outfile)
% Read a collection of sqw files with a common grid and write to a single sqw file
% Currently the input files are restricted to have been made from a single spe file
%
%   >> write_nsqw_to_nsqw (infiles, outfile)
%
% Input:
%   infiles         Cell array or character array of file name(s) of input file(s)
%   outfile         Full name of output file
%
% T.G.Perring   27 June 2007
% I.Bustinduy   20 Sept 2007

% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------

small = 1.0d-4;    % I.Bustinduy's  'small' quantity for cautious dealing of borders. 
                   % If it's so restrictive as 1.0d-10, then most of the '.tmp' files must be unnecesarily re-done. 
% Convert to cell array of strings if necessary
if ~iscellstr(infiles)
    infiles=cellstr(infiles);
end

% Check input files exist
nfiles=length(infiles);
for i=1:nfiles
    if exist(infiles{i},'file')~=2
        error(['ERROR: File ',infiles{i},' not found'])
    end
end

% *** Check output file can be opened
% *** Check that output files and input file do not coincide
% *** Check do not repeat an input file name

% Read header information from files, and check consistency
% ---------------------------------------------------------
% (*** At present we require that all detector info is the same for all files, and each input file contains only one spe file)
disp(' ')
disp('Reading header(s) of input file(s) and checking consistency...')

% Read data:
main_header=cell(nfiles,1);
header=cell(nfiles,1);
%datahdr=cell(nfiles,1); % datahdr won't be a cell array.
pos_datastart=zeros(nfiles,1);
pos_npixstart=zeros(nfiles,1);
pos_pixstart=zeros(nfiles,1);
npixtot=zeros(nfiles,1);

mess_completion(nfiles,5,0.1);   % initialise completion message reporting
for i=1:nfiles
disp(['Checking ',infiles{i},' header'])%    disp(['i:',num2str(i)]) 
    [main_header{i},header{i},det_tmp,datahdr_tmp,mess,position,npixtot_tmp,type] = get_sqw (infiles{i},'-h');
    % Loading data-s into datahdr{i} structure makes imposible to read more
    % than ~50 files !!! is this a Bug?
    % Possible solution: we only need some fields: -.uoffset -.u_to_rlu
    % -.ulen -.iax -.iint -.pax
    if(isempty(npixtot_tmp)), npixtot(i)=NaN; else npixtot(i)=npixtot_tmp; end
    if ~isempty(mess); error('Error reading data from file %s \n %s',infiles{i},mess); end
    if ~strcmpi(type,'a'); error(['No pixel information in ',infiles{i}]); end
    if main_header{i}.nfiles~=1; error(['Data from more than one spe file in ',infiles{i}]); end
    if i==1
        det=det_tmp;    % store the detector information for the first file
    end
    if ~isequal_par(det,det_tmp); error('Detector parameter data is not the same in all files'); end
    clear det_tmp       % save memory on what could be a large variable
    pos_datastart(i)=position.data;  % start of data block
    pos_npixstart(i)=position.npix;  % start of npix field
    pos_pixstart(i) =position.pix;   % start of pix field
    mess_completion(i)

    % Check consistency:
    % (***At present, we insist that lattice parameters, u_to_rlu, and uoffset are identical. This may be
    % generalisable however) I. Bustinduy
    
    if(nfiles==1),
       firstdatahdr=datahdr_tmp;
       %urange_tmp=firstdatahdr.urange;
    end
    if(nfiles>1),
        if(i==1),
            firstdatahdr=datahdr_tmp;
            %urange_tmp=firstdatahdr.urange;
        else
            npax=length(firstdatahdr.pax);
            %small = 1.0e-10;% test number to define equality allowing for rounding
            %urange_tmp=[min(urange_tmp(1,:),datahdr_tmp.urange(1,:));max(urange_tmp(2,:),datahdr_tmp.urange(2,:))];

            ok = all(abs(datahdr_tmp.uoffset-firstdatahdr.uoffset)<small);
            ok = ok & all(abs(datahdr_tmp.u_to_rlu-firstdatahdr.u_to_rlu)<small);
            if ~ok
                error(['Not all input files have the same projection axes and projection axes offsets in data blocks, stopped at:', infiles{i}])
            end

            if length(datahdr_tmp.pax)~=npax
                error(['Input files must all have the same number of projection axes, stopped at:', infiles{i}])
            end
            if npax<4   % one or more integration axes
                ok = all(datahdr_tmp.iax==firstdatahdr.iax);
                ok = ok & all(datahdr_tmp.iint==firstdatahdr.iint);
                if ~ok
                    error(['Not all integration axes and integration limits are identical, stopped at:', infiles{i}]')
                end
            end
            if npax>0   % one or more projection axes
                ok = all(datahdr_tmp.pax==firstdatahdr.pax);
                for ipax=1:npax
                    ok = ok & all((abs(datahdr_tmp.p{ipax})-abs(firstdatahdr.p{ipax}))<small);
                end
                if ~ok
                    error(['Not all projection axes and bin boundaries are identical, stopped at:', infiles{i}]);
                    disp('General urange:')
                    disp([num2str(min(firstdatahdr.p{1})),' ',num2str(min(firstdatahdr.p{2})),' ',num2str(min(firstdatahdr.p{3})),' ',num2str(min(firstdatahdr.p{4}))])
                    disp([num2str(max(firstdatahdr.p{1})),' ',num2str(max(firstdatahdr.p{2})),' ',num2str(max(firstdatahdr.p{3})),' ',num2str(max(firstdatahdr.p{4}))])
                    disp([infiles{i},' urange:'])
                    disp([num2str(min(datahdr_tmp.p{1})),' ',num2str(min(datahdr_tmp.p{2})),' ',num2str(min(datahdr_tmp.p{3})),' ',num2str(min(datahdr_tmp.p{4}))])
                    disp([num2str(max(datahdr_tmp.p{1})),' ',num2str(max(datahdr_tmp.p{2})),' ',num2str(max(datahdr_tmp.p{3})),' ',num2str(max(datahdr_tmp.p{4}))])
                    keyboard
                end
            end
        end
    end
end
% we can leave all header info. since it does not take so much memory
for i=2:nfiles  % only need to check if more than one file
    ok = all(abs(header{i}.alatt-header{1}.alatt)<small);
    ok = ok & all(abs(header{i}.angdeg-header{1}.angdeg)<small);
    ok = ok & all(abs(header{i}.uoffset-header{1}.uoffset)<small);
    ok = ok & all(abs(header{i}.u_to_rlu-header{1}.u_to_rlu)<small);
    if ~ok
        error('Not all input files have the same lattice parameters,projection axes and projection axes offsets in header blocks')
    end
end

mess_completion

% ! Here, a code block ?which expected all data_hdr to be loaded in memory? was removed by I. Bustinduy

% Now read in binning information
% ---------------------------------
% We did not read in the arrays s, e, npix from the files because if have a 50^4 grid then the size of the three
% arrays is is total 24*50^4 bytes = 150MB. Firstly, we cannot afford to read all of these arrays as it would
% require too much RAM (30GB if 200 spe files); also if we just want to check the consistency of the header information
% in the files first we do not want to spend lots of time reading and accumulating the s,e,npix arrays. We can do
% that now, as we have checked the consistency.
disp(' ')
disp('Reading and accumulating binning information of input file(s)...')

% Read data:
mess_completion(nfiles,5,0.1);   % initialise completion message reporting
for i=1:nfiles
    fid=fopen(infiles{i},'r');
    if fid<0; error(['Unable to open input file ',infiles{i}]); end
    
    status=fseek(fid,pos_datastart(i),'bof'); % Move directly to location of start of data section
    if status<0; fclose(fid); error(['Error finding location of binning data in file ',infiles{i}]); end
    
    [bindata,mess]=get_sqw_data(fid,'-nopix');
    if i==1
        s_accum = bindata.s;
        e_accum = bindata.e;
        npix_accum = bindata.npix;
    else
        s_accum = s_accum + bindata.s;
        e_accum = e_accum + bindata.e;
        npix_accum = npix_accum + bindata.npix;
    end
    fclose(fid);            % close file so that do not have lots of files open at once
    mess_completion(i)
end
mess_completion


% Write to output file
% ---------------------------
disp(' ')
disp(['Writing to output file ',outfile,' ...'])

[path,name,ext,ver]=fileparts(outfile);
main_header_combined.filename=[name,ext,ver];
main_header_combined.filepath=[path,filesep];
main_header_combined.title='';
main_header_combined.nfiles=nfiles;

sqw_data.uoffset=firstdatahdr.uoffset;
sqw_data.u_to_rlu=firstdatahdr.u_to_rlu;
sqw_data.ulen=firstdatahdr.ulen;
sqw_data.ulabel=firstdatahdr.ulabel;
sqw_data.iax=firstdatahdr.iax;
sqw_data.iint=firstdatahdr.iint;
sqw_data.pax=firstdatahdr.pax;
sqw_data.p=firstdatahdr.p;
sqw_data.dax=firstdatahdr.dax;    % take the display axes from first file, for sake of choosing something
sqw_data.s=s_accum;
sqw_data.e=e_accum;
sqw_data.npix=npix_accum;
sqw_data.urange=firstdatahdr.urange;%urange_tmp;

% ! removed by I. Bustinduy
% % for i=2:nfiles
% %     sqw_data.urange=urange_tmp;[min(sqw_data.urange(1,:),datahdr{i}.urange(1,:));max(sqw_data.urange(2,:),datahdr{i}.urange(2,:))];
% % end

run_label='fileno';
mess = write_sqw (outfile, main_header_combined, header, det, sqw_data, '-pix', infiles, pos_npixstart, pos_pixstart, run_label);
if ~isempty(mess); error('Problems writing to output file %s \n %s',outfile,mess); end

