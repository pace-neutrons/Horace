function fid = verify_and_reopen_input_files_(pix_comb_info)
% reopens input files for reading or verify if these files are opened.
% Inputs:
% pix_comb_info    -- the class containing the information about the input
%                     files to combine, namely the fields:
%
%   infiles         Cell array of file names, or array of file identifiers of open files, from
%                   which to accumulate the pixel information
%   pos_npixstart   Position (in bytes) from start of file of the start of the field npix
%   pos_pixstart    Position (in bytes) from start of file of the start of the field pix
%   npix_cumsum     Accumulated sum of number of pixels per bin across all the files
%   run_label       Indicates how to re-label the run index (pix(5,...)
%                       'fileno'        relabel run index as the index of the file in the list infiles
%                       'nochange'      use the run index as in the input file
%                        numeric array  offset run numbers for ith file by ith element of the array
%                   This option exists to deal with three limiting cases:
%                    (1) The run index is already written to the files correctly indexed into the header
%                       e.g. as when temporary files have been written during cut_sqw
%                    (2) There is one file per run, and the run index in the header block is the file
%                       index e.g. as in the creating of the master sqw file
%                    (3) The files correspond to several runs in general, which need to
%                       be offset to give the run indices into the collective list of run parameters
%
% Output:
% fid            array of handles of files open for read operations.

%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%


nfiles = pix_comb_info.nfiles;

% Open all input files and move to the start of the pixel information
% [Currently opens all the input files simultaneously.  (TGP desktop PC on 1 July 2007 machine will open up to 509 files when tested)
% Opening all files may cause problems as I don't know what the reasonable default is, but I assume is faster than constantly opening
% and closing a hundred or more files]
if isnumeric(pix_comb_info.infiles)
    fid = pix_comb_info.infiles;   % copy fid
    for i=1:nfiles
        if isempty(fopen(fid(i)))
            error('SQW_FILE_IO:runtime_error',...
                'No open file N %d with file identifier %d',i,fid(i));
        end
    end
else
    fid=zeros(nfiles,1);
    for i=1:nfiles
        [fid(i),mess]=fopen(pix_comb_info.infiles{i},'r');
        if fid(i)<0
            for j=1:i-1; fclose(fid(j)); end    % close all the open input files
            error('SQW_FILE_IO:runtime_error',...
                'Unable to open all input files concurrently: %s',mess);
        end
    end
    
    for i = 1:nfiles
        fseek(fid(i),pix_comb_info.pos_pixstart(i),'bof'); % Move directly to location of start of pixel data
        check_error_report_fail_(fid(i),...                % to ensure this is possible
            sprintf('Unable to move to the start of the pixel record for the  input file N%d after mex-combine failed',...
            i));
    end
end
