function [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = cut_data_from_file (S, nstart, nend, keep_pix,...
    urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin, pix_tmpfile_ok)
% Accumulates pixels into bins defined by cut parameters
%
%   >> [s, e, npix, npix_retain] = cut_data (fid, nstart, nend, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin, keep_pix)
%
% Input:
% ------
%   fid             sqwfile information structure for a currently open sqw file
%   nstart          Column vector of read start locations in file
%   nend            Column vector of read end locations in file
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   urange_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%   nbin            Number of bins along the projection axes with two or more bins [row vector]
%   pix_tmpfile_ok  Indicates if temporary buffer files can be used to hold pixel information
%                  keep_pix==true (ignored if keep_pix==false)
%                       pix_tmpfile_ok = false: Require that output argument pix is 9xn array of u1,u2,u3,u4,irun,idet,ien,s,e
%                                              for each retained pixel
%                       pix_tmpfile_ok = true:  Buffering of pixel info to temporary files if the number of pixels exceed a threshold
%                                              In this case, output argument pix contains details of temporary files (see below)
%
% Output:
% -------
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels (if keep_pix==true, otherwise pix=[])
%   urange_step_pix Actual range of contributing pixels
%   pix             Pixel information
%                       If keep_pix=false, pix=[];
%                       If keep_pix==true, then contents depend on value of pix_tmpfile_ok:
%                           If pix_tmpfile_ok = false:
%                               contains u1,u2,u3,u4,irun,idet,ien,s,e for each retained pixel
%                           If pix_tmpfile_ok = true:
%                               If number of pixels less than threshold, then
%                              contains u1,u2,u3,u4,irun,idet,ien,s,e for each retained pixel
%
%                               If the number of pixels exceeded the threshold, then
%                              is an array of sqwfile structures with information about the
%                              contents of the temporary files.
%   npix_retain     Number of pixels that contribute to the cut
%   npix_read       Number of pixels read from file
%
%
% Note:
% - Redundant input variables in that urange_step(2,pax)=nbin in implementation of 19 July 2007
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007 (based on earlier prototype TGP code)
% $Revision$ ($Date$)


horace_info_level=get(hor_config,'horace_info_level');
tmpfiledir=get_tmpfiledir;  % get temporary file location
tmpfilename_stub=['horace_cut_',rand_digit_string(16)];

% Buffer sizes
vmax = get(hor_config,'mem_chunk_size');    % maximum length of buffer array in which to accumulate points from the input file
pmax = vmax;                                % maximum length of array in which to buffer retained pixels (pmax>=vmax)

% Get to location in file from which to read pixel information
fid=S.fid;
fseek(fid,S.position.pix,'bof');  % Move directly to location of start of pixel data block

% Output arrays for accumulated data
% Note: matlab sillyness when one dimensional: MUST add an outer dimension of unity. For 2D and higher,
% outer dimensions can always be assumed. The problem with 1D is that e.g. zeros([5]) is not the same as zeros([5,1])
% whereas zeros([5,3]) is the same as zeros([5,3,1]).
if isempty(nbin); nbin_as_size=[1,1]; elseif length(nbin)==1; nbin_as_size=[nbin,1]; else nbin_as_size=nbin; end;  % usual Matlab sillyness
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf];
npix_retain = 0;

noffset = nstart-[0;nend(1:end-1)]-1;   % offset from end of one block to the start of the next
range = nend-nstart+1;                  % length of the block to be read
npix_read = sum(range(:));              % number of pixels that will be read from file

% Buffer array for retained pixels
pmax = max(pmax,vmax);  % must have pmax>=vmax in current algorithm
Stmp = sqwfile;         % buffer file details (create even if not needed, to keep tidy closedown simple)
if keep_pix
    if pix_tmpfile_ok
        nfile=0;        % number of files in which pixel information has been buffered
        ppos=1;         % position in pix where the next pixels to be buffered are to start
        pix = zeros(9,min(pmax,npix_read));
        ix = zeros(min(pmax,npix_read),1);
    else
        pix = zeros(9,0);   % changed 17/11/08 from pix = [];
        ix = [];
    end
else
    pix = [];   % pix is a return argument, so must give it a value
end

% Work array into which to read data
v = zeros(9,min(vmax,npix_read));  % coordinates, signal and error as read from file - make it no longer than necessary

% number of blocks to be read from hdd -- used in the progress indicator.
nsteps=floor(npix_read/vmax)+1;
i_step=0;

vpos = 1;               % start of new work array (vpos gives position of next point to be filled in the work array v)
t_read  = [0,0];
t_accum = [0,0];
t_sort  = [0,0];

if horace_info_level>=2
    disp('-----------------------------')
    fprintf(' Cut data from file started at:  %4d;%02d;%02d|%02d;%02d;%02d\n',fix(clock));
end

if horace_info_level>=1, bigtic(1), end
for i=1:length(range)
    rpos = 1;       % start of new range (rpos gives position of next point to read in the current range
    status = fseek (fid, (4*9)*noffset(i), 'cof'); % initial offset is from end of previous range; 9 x float32 per pixel in the file
    if status~=0; sqwfile_close(Stmp,'delete'); error('Unable to jump to required location in file'); end;
    while rpos <= range(i)
        if vpos<=vmax   % work array not yet filled up
            if range(i)-rpos+1 <= vmax-vpos+1   % enough space to hold remainder of range
                vend = vpos+range(i)-rpos;  % last column that will be filled in this loop of the while statement
                try
                    tmp = fread(fid, [9,range(i)-rpos+1], '*float32');
                    v(:,vpos:vend)=double(tmp);
                    clear tmp
                catch   % fixup to account for not reading required number of items
                    mess = 'Unrecoverable read error';
                    sqwfile_close(Stmp,'delete'); error(mess);
                end
                vpos = vend+1;
                break   % jump out of while loop
            else    % read in as much of the range as can
                try
                    tmp = fread(fid, [9,vmax-vpos+1], '*float32');
                    v(:,vpos:vmax)=double(tmp);
                    clear tmp
                catch   % fixup to account for not reading required number of items
                    mess = 'Unrecoverable read error';
                    sqwfile_close(Stmp,'delete'); error(mess);
                end
                rpos = rpos+vmax-vpos+1;
                vpos = vmax+1;
            end
        else            % work array filled up; process the data read up to now, and reset position in work array to beginning
            if horace_info_level>=1
                t_read = t_read + bigtoc(1);
                bigtic(2)
            end
            if horace_info_level>=0
                i_step=i_step+1;
                mess=sprintf('Step %3d of %4d; Have read data for %d pixels -- now processing data...',i_step,nsteps,vpos-1);
                disp(mess)
            end
            [s, e, npix, urange_step_pix, del_npix_retain, okpix, ix_add] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix, ...
                v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
            if horace_info_level>=0, disp(['                  ------->  retained  ',num2str(del_npix_retain),' pixels']), end
            npix_retain = npix_retain + del_npix_retain;
            if horace_info_level>=1, t_accum = t_accum + bigtoc(2); end
            vpos = 1;
            if keep_pix
                if horace_info_level>=1, bigtic(3), end
                accumulate_pix(false)
                if horace_info_level>=1, t_sort = t_sort + bigtoc(3); end
            end
            if horace_info_level>=1, bigtic(1), end
        end
    end
end
if horace_info_level>=1, t_read = t_read + bigtoc(1); end

if vpos>1   % flush out work array - the array contains some unprocessed data
    if horace_info_level>=1, bigtic(2), end
    if horace_info_level>=0
        i_step=i_step+1;
        mess=sprintf('Step %3d of %4d; Have read data for %d pixels -- now processing data...',i_step,nsteps,vpos-1);
        disp(mess)
    end
    [s, e, npix, urange_step_pix, del_npix_retain, okpix, ix_add] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix, ...
        v(:,1:vpos-1), urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
    if horace_info_level>=0, disp(['                  ------->  retained  ',num2str(del_npix_retain),' pixels']), end
    
    npix_retain = npix_retain + del_npix_retain;
    if horace_info_level>=1, t_accum = t_accum + bigtoc(2); end
    if keep_pix
        if horace_info_level>=1, bigtic(3), end
        accumulate_pix(true)
        if horace_info_level>=1, t_sort = t_sort + bigtoc(3); end
    end
end

if horace_info_level>=1
    disp('-----------------------------')
    disp('Inside cut_data:')
    disp ('  Timings for reading:')
    disp(['        Elapsed time is ',num2str(t_read(1)),' seconds'])
    disp(['            CPU time is ',num2str(t_read(2)),' seconds'])
    disp(' ')
    disp ('  Timings in accumulate_cut:')
    disp(['        Elapsed time is ',num2str(t_accum(1)),' seconds'])
    disp(['            CPU time is ',num2str(t_accum(2)),' seconds'])
    if keep_pix
        disp(' ')
        disp ('  Timings for handling pixel information')
        disp(['        Elapsed time is ',num2str(t_sort(1)),' seconds'])
        disp(['            CPU time is ',num2str(t_sort(2)),' seconds'])
    end
    if horace_info_level>=2
        disp('-----------------------------')
        fprintf(' Cut data from file finished at:  %4d;%02d;%02d|%02d;%02d;%02d\n',fix(clock));
    end
    
    disp('-----------------------------')
    disp(' ')
end

% Nested function to handle case of keep_pixels. Nested so that variables are shared with main function to optimise memory use
% Note: the routine implicitly assumes that pmax>=max(length(ok))==vmax. Routine works even if no pixels retained
    function accumulate_pix (finish)
        if pix_tmpfile_ok
            if del_npix_retain>0    % accumulate pixels if any read in
                if ppos+del_npix_retain-1>pmax        % not enough room left in buffer to add more pixels
                    pend = ppos-1;          % current end of buffer arrays (can only reach here if already data in buffer arrays)
                    accumulate_pix_to_file  % flush current pixel information to file and reset buffer arrays
                end
                pend = ppos+del_npix_retain-1;
                accumulate_pix_to_memory    % add the new pixels to the buffers
            end
            pend = ppos-1;
            if finish && pend>0
                if nfile==0     % no buffer files written - the buffer arrays are large enough to hold all retained pixels
                    [ix,ind]=sort(ix(1:pend));  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
                    pix=pix(:,ind); % reorders pix
                else    % at least one buffer file; flush the buffers to file
                    accumulate_pix_to_file
                    clear pix ix v ok ix_add    % clear big arrays so that final output variable pix is not way up the stack
                    pix = Stmp;    % put file details into pix
                end
            end
        else
            if del_npix_retain>0    % accumulate pixels if any read in
                pix = [pix,v(:,okpix)];
                ix  = [ix;ix_add];
            end
            if finish && ~isempty(pix)  % prepare the output pix array
                use_mex=get(hor_config,'use_mex');
                clear v ok ix_add; % clear big arrays
                
                if use_mex
                    try
                        pix = sort_pixels_by_bins(pix,ix,npix);
                        clear ix ;  % clear big arrays
                    catch
                        use_mex=false;
                        if horace_info_level>=1
                            message=lasterr();
                            warning(' Can not sort_pixels_by_bins using c-routines, reason: %s \n using Matlab',message)
                        end
                    end
                end
                if ~use_mex
                    [ix,ind]=sort(ix);  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
                    clear ix ;          % clear big arrays so that final output variable pix is not way up the stack
                    pix=pix(:,ind);     % reorders pix
                end
            end
        end
        
        function accumulate_pix_to_memory
            pix(:,ppos:pend) = v(:,okpix);    % accumulate pixels into buffer array
            ix(ppos:pend) = ix_add;
            ppos = pend+1;
        end
        
        function accumulate_pix_to_file
            % Increment buffer file number and create temporary file name
            nfile = nfile + 1;
            tmpfilename=fullfile(tmpfiledir,[tmpfilename_stub,'_',num2str(nfile),'.tmp']);
            % Create properly ordered npix and pix arrays for writing to temporary file
            [ix,ind]=sort(ix(1:pend));    % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
            npix_buffer = zeros(size(npix(:)));                 % Fill array with zeros
            % Fill the bin numbers with >0 no points: bin number(s)=ix(diff([-Inf;ix])~=0); number of pix=diff(find(diff([-Inf;ix;Inf])~=0))
            % (algorithm works even if ix is empty)
            npix_buffer(ix(diff([-Inf;ix])~=0)) = diff(find(diff([-Inf;ix;Inf])~=0));
            pix=pix(:,ind);  % reorders pix
            % Write to temporary file
            [Stmp(nfile),messput]=sqwfile_open(tmpfilename,'new');
            if ~isempty(messput), sqwfile_close(Stmp,'delete'); error(messput); end
            [ok,messput,Stmp(nfile)] = put_sqw (Stmp(nfile), struct('npix',npix_buffer,'pix',pix));
            if ~isempty(messput), sqwfile_close(Stmp,'delete'); error(messput); end
            clear pix ix npix_buffer    % tidy memory
            % Re-prepare buffer arrays
            ppos=1;
            pix = zeros(9,min(pmax,npix_read));
            ix = zeros(min(pmax,npix_read),1);
        end
    end

end
