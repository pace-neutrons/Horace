classdef test_nsqw2sqw_internal_methods < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tempdir();
        tests_dir;
    end
    
    methods
        function this=test_nsqw2sqw_internal_methods(name)
            if ~exist('name','var')
                name = 'test_nsqw2sqw_internal_methods';
            end
            this = this@TestCase(name);
            class_dir = fileparts(which('test_nsqw2sqw_internal_methods.m'));
            this.tests_dir = fileparts(class_dir);
        end
        %
        function test_nbin_for_pixels(obj)
            n_files = 10;
            n_bins = 41;
            npix_processed = 0;
            npix_per_bins = ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,31]);
            assertEqual(numel(npix_in_bins),31);
            %
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,21]);
            assertEqual(numel(npix_in_bins),21);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,20]);
            assertEqual(size(npix_per_bins),[10,1]);
            assertEqual(numel(npix_in_bins),1);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,410);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,0]);
            assertTrue(isempty(npix_in_bins));
            %--------------------------------------------------------------
            
            npix_per_bins = 10*ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            npix_processed = 0;
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,40]);
            assertEqual(numel(npix_in_bins),40);
            
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            
            npix_per_bins = 11*npix_per_bins;
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,300);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),100);
            assertEqual(npix_2_read(2),0);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),10);
            assertEqual(npix_2_read(2),90);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,500);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),0);
            assertEqual(npix_2_read(2),20);
            assertEqual(npix_2_read(3),80);
            assertEqual(npix_2_read(4),0);
        end
        
        function test_read_pix(obj)
            
            n_files = 10;
            fid = 1:n_files;
            run_label = 2*(1:n_files);
            pos_pixstart = zeros(n_files,1);
            npix_per_bin = randi(10,n_files,5)-1;
            
            rd =combine_sqw_job_tester();
            [pix_section,pos_pixstart]=rd.read_pix_for_nbins_block(...
                fid,pos_pixstart,npix_per_bin,run_label,true,false);
            
            assertEqual( pos_pixstart,sum(npix_per_bin,2));
            assertEqual(size(pix_section),[9,sum(sum(npix_per_bin))]);
            %assertEqual(size(pix_section{2}),[9,sum(npix_per_bin(:,2))]);            
            %assertEqual(size(pix_section{3}),[9,sum(npix_per_bin(:,3))]);                        
        end
    end
end
