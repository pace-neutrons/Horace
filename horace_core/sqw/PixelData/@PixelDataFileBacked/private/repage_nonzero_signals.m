function nz_numpix = repage_nonzero_signals( ...
                     page_sizes, ... % new pages sizes for signals in this PDFB
                     nzsigpos ...    % array of the non-zero pixel positions (independent 
        ...             % of the paging applied to them
    )
    % pre-allocate non-zero signal position sizes as we already know how
    % many pages there are
    nz_numpix = zeros(1, numel(page_sizes));

    %maxnzsigpos()

    % start looking at the signals with the start of the first page, i.e.
    page_start = 1;

    % we will be reading nzsigpos in chunks of the size: nzsigpos_buffersize
    % this is a convenient measure of the maximum amount we can get from
    % the file in one go without disturbing the allowed sizes on disc
    nzsigpos_buffersize = max(page_sizes);

    % we will read the non-zero signal positions into the buffer for each page
    % starting (unsurprisingly) at the beginning
    nzsigpos_bufferstart = 1;

    % we then look for each page of signals (zero and well as non-zero) and
    % find the highest non-zero signal position in the page

    for ii = 1:numel(page_sizes) % these are the normal page sizes for the pixels
                                 % for the current (new)
                                 % PixelDataFilebacked object

        % we search up to the max end position for this page. not further
        % than end of nzsigpos
        nzsigpos_bufferend = nzsigpos_bufferstart + nzsigpos_buffersize;
        nzsigpos_bufferend = min( numel(nzsigpos), nzsigpos_bufferend);
        % so the buffer with the non-zero signal positions for this page is
        nzsigpos_buffer = nzsigpos(nzsigpos_bufferstart:nzsigpos_bufferend);

        % the pages are for finding where the new pages boundaries are in 
        % the non-zero signal position array nzsigpos
        
        page_size = page_sizes(ii);
        page_end = page_start + page_size -1 ;
        %page_end = min(page_end, maxnzsigpos); % largest signal position in 
                                               % page OR end of non-zero
                                               % signal positions
        % find the non-zero signal positions in this page only
        % so not beyond the page_end position
        nzsigpos_buffer_thispage = nzsigpos_buffer(nzsigpos_buffer<=page_end);

        % the number of non-zero pixel positions for this page is the size
        % of the thispage buffer; store and record
        nz_npix = numel(nzsigpos_buffer_thispage);
        nz_numpix(ii) = nz_npix;

        % move on the start of the buffer so it is picked up at the start
        % of the next for loop iteration
        nzsigpos_bufferstart = nzsigpos_bufferstart + nz_npix;
        page_start = page_end;
    end
        
        



        



%{
def rechunk(
        old_npix,
        new_npix,    % new bin/page sizes
        signz,       % non-zero signals 
        sigpos       % indices of nz signals in uncompressed array
    ):
    for np in new_npix:
        pass

    % the file we're reading has sigpos, the set of indices into the full list of detector signals
    % we're on page 1 in the new paging, the upper index on this page is np
    % we want to find the index in sigpos M which <= np
    % remember this is only the first page we've read and we're not certain how much of it is
    % nb sigpos is absolute indexes not per page
    % so we read the first old page
    % check if last index > np
    % read subsequent pages until last index > np
    % use F=find(sigpos<=np) to get the indices we want on this last page
    % we only need this for the first run through with the new npix; if new_npix==old_npix then we 
    % just use new_npix for the paging.
    % we try to put this into the pixel read, so start by engineering there

    op = 1; % start looking at old pages with the first page
    maxidxsofar = 0;
    for np = 1:n_new_pages
        newpagesize = newpagesizes(np); % page sizes of the full dataset, not 
                                        % just the non-zero elements
        for op = op1:n_old_pages
            oldpagesize = oldpagesizes(op); % page sizes for non-zero pixels only
            possig = possig_array(op);      % the absolute position in the original data

            maxidxsofar = maxidxsofar + newpagesize;
            idxs = find(possig<maxidxsofar);
            maxidx = max(idxs);
            if maxidx>newpagesize
        end
        end
        
        pagesize = new_page_sizes(1);
        for op = 1:n_old_pages
            psig = possig()
        end
end
%}