classdef fake_mess_provider < handle
    % Class used to generate fake messages, emulating
    % data, received from readers during combine pixels job
    %
    % used in test_nsqw2sqw_internal methods
    %
    properties
        pix_block;
        file_blocks;
        pix_combined;
        
        combined_pix_data=[]; 
        
        
        % the number of pixels to use as fake "cache"
        buf_size = 100;
        % total number of bins used as keys to pixels database
        n_bins = 100;
        %
        npix_start;%  first pixel to read for messages
        nbin_start;        
    end
    properties(Dependent)
        n_files
    end
    
    methods
        function obj = fake_mess_provider(n_pixels,n_bins,...
                n_files,buf_size)
            % build pixels block for testing pixels cache and combine algorithm.
            %
            % Inputs:
            % n_pixels -- number of pixels in the pix block
            % n_bins   -- number of bins these pixels should be randomly distributed
            %             over
            % n_files  -- number of files, these pixels are randomly distributed over
            % buf_size -- the number of pixels to process per split operation            
            %
            % Constructs:
            % pix_block   [9xn_pixels] fake array, containing
            % column Number:
            %    1         the number of the bin a pixel is located in
            %    2         the number of file the pixel belongs to
            %    3         tag (number) of a pixel, allowing to identify this pixel.
            %    4-9       zeros.
            % the data are sorted by bins i.e. first bin pixels are located first,
            % second bin follow after, etc.
            %
            % file_blocks -- cellarray of n_files extracts from pix_block, where each
            %                each block contains only pixels, belonging to a "file"
            
            obj.pix_block = zeros(9,n_pixels);
            obj.pix_block(1,:) = floor(rand(n_pixels,1)*n_bins)+1;
            obj.pix_block(2,:) = floor(rand(n_pixels,1)*n_files)+1;
            obj.n_bins = n_bins;
            
            [~,ind] = sort(obj.pix_block(1,:));
            obj.pix_block = obj.pix_block(:,ind);
            obj.pix_block(3,:) = 1:n_pixels;
            
            obj.file_blocks = cell(n_files,1);
            for i=1:n_files
                in_file = obj.pix_block(2,:)==i;
                obj.file_blocks{i} = obj.pix_block(:,in_file);
            end
            
            obj.nbin_start = ones(n_files,1);
            obj.npix_start = ones(n_files,1);
            if nargin>3
                obj.buf_size = buf_size;
            end            
            
        end
        %
        function nf = get.n_files(obj)
            nf = numel(obj.file_blocks);
        end
        %
        function [messages,varargout] = receive_all(obj,varargin)
            % split pix block into messages block. e.g prepare n_files messages, whith
            % pixels, contributing into these bins.
            %
            % Output:
            % messages       -- cellarray of messages containing pix information. See
            %
            %                   pix_cache about the format of these messages
            
            np_start = obj.npix_start;
            nb_start = obj.nbin_start;
            
            npix_end = np_start ;
            nbin_end = nb_start;
            
            
            payload = struct('npix',[],'n_source',0,'bin_range',[0,0],'pix_data',[],...
                'bin_edges',[],'flld_bin_ind',[],'last_bin_completed',true);
            
            nf = obj.n_files;
            
            messages = cell(nf,1);
            
            for i=1:nf
                data = obj.file_blocks{i};
                messages{i} = DataMessage();
                npix1 = np_start(i);
                npix_end(i) = npix1+obj.buf_size-1;
                np_start(i) = npix_end(i)+1;
                
                if npix_end(i) >size(data,2)
                    npix_end(i) = size(data,2);
                    np_start(i) = npix_end(i)+1;
                end
                npix2 = npix_end(i);
                if npix1>npix2
                    messages{i} = [];
                    continue;
                end
                pix_tb = data(:,npix1:npix2);
                
                nbin_end_i   = pix_tb(1,end);
                payload.bin_range = [nb_start(i),nbin_end_i];
                
                
                %
                payload.n_source = i;        % last bin
                if (npix2 == size(data,2) || data(1,npix2)~=data(1,npix2+1))
                    payload.last_bin_completed =true;
                    if (npix2 == size(data,2))
                        payload.bin_range(2) =  obj.n_bins;
                        nbin_end_i = obj.n_bins;
                    end
                    nbin_end(i) = nbin_end_i+1;
                else
                    payload.last_bin_completed =false;
                    nbin_end(i) = nbin_end_i;
                end
                payload.npix = size(pix_tb,2);
                
                [flld_bin_ind,bin_edges] = unique(pix_tb(1,:));
                % last bin edge is one higher vrt real bin edge as right
                % bin edge is constructed from left edges and last by
                % extracting 1
                bin_edges  = [bin_edges;payload.npix+1] ;
                
                bin_sequence = nb_start(i):nbin_end_i;
                if numel(bin_sequence)>numel(flld_bin_ind)
                    % expand bin edges with zero bins
                    bin_edges_expanded = zeros(numel(bin_sequence)+1,1);
                    
                    n_bin = 1;
                    for j=1:numel(bin_sequence)
                        %             if n_bin > numel(flld_bin_ind)
                        %                 warning(' wrong bin edges');
                        %             end
                        
                        bin_edges_expanded(j) = bin_edges(n_bin);
                        if n_bin<=numel(flld_bin_ind) && bin_sequence(j)==flld_bin_ind(n_bin)
                            n_bin = n_bin+1;
                        end
                    end
                    bin_edges_expanded(end) = bin_edges(end);
                    
                    bin_edges = bin_edges_expanded;
                end
                
                payload.bin_edges      = bin_edges;
                %payload.flld_bin_ind   = flld_bin_ind;
                payload.pix_data       = pix_tb;
                messages{i}.payload    = payload;
            end
            
            non_empty = cellfun(@(ms)(~isempty(ms)),messages,'UniformOutput',true);
            messages = messages(non_empty);
            
            obj.nbin_start  = nbin_end;
            obj.npix_start  = npix_end+1;   
            if nargout > 1
                varargout{1} = cellfun(@(ms)(ms.payload.n_source),messages,...
                    'UniformOutput',true);
            end
        end
    end
end

