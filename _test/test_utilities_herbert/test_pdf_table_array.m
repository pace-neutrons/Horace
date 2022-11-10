classdef test_pdf_table_array < TestCaseWithSave
    properties
        pdf_gauss;
        pdf_hat;
        pdf_tri;
        pdf_hh;

        w_gauss;
        w_hat;
        w_tri;
        w_hh;

        x_gauss_bin;
        x_hat_bin;
        x_tri_bin;
        x_hh_bin;
        
        home_folder;
    end
    methods
        function obj = test_pdf_table_array(varargin)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_pdf_table_array';
            else
                name = varargin{1};
            end
            file = fullfile(home_folder,'test_pdf_table_array_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;

            % Create individual pdfs
            % ----------------------
            % Gaussian
            % ----------
            obj.x_gauss_bin = -5:0.05:7;
            x_gauss = obj.x_gauss_bin(1:end-1) + 0.025;
            y_gauss = gauss(x_gauss,[10,1,1.5]);
            w_gauss = IX_dataset_1d(x_gauss,y_gauss);
            area = integrate(w_gauss);
            obj.w_gauss = w_gauss/area.val;
            obj.pdf_gauss = pdf_table(x_gauss,@gauss,[10,1,1.5]);

            % Hat
            % ----
            % (will construct a plot of the distribution later)
            x_hat = [-2,3]; % just two points - pushes to the limit
            y_hat = [1,1];
            obj.pdf_hat = pdf_table(x_hat,y_hat);
            % (now carefully construct a set of bin boundaries that can be used in the
            % random sampling to compare)
            obj.x_hat_bin = -3:0.05:4;
            y_hat_bin = zeros(size(obj.x_hat_bin));
            y_hat_bin(obj.x_hat_bin>=-2 & obj.x_hat_bin<2.99999) = 1;
            w_hat = IX_dataset_1d(obj.x_hat_bin,y_hat_bin(1:end-1));
            val = integrate(w_hat);
            obj.w_hat = w_hat/(val.val);

            % Triangle
            % ---------
            obj.x_tri_bin = -6:0.05:9;
            x_tri = obj.x_tri_bin(1:end-1) + 0.025;
            y_tri = conv_hh(x_tri,3,3);
            obj.w_tri = IX_dataset_1d(x_tri,y_tri);
            obj.pdf_tri = pdf_table(x_tri,@conv_hh,3,3);

            % hat*hat
            % -------
            obj.x_hh_bin = -4:0.05:8;
            x_hh = obj.x_hh_bin(1:end-1) + 0.025;
            y_hh = conv_hh(x_hh,2,4);
            obj.w_hh = IX_dataset_1d(x_hh,y_hh);
            obj.pdf_hh = pdf_table(x_hh,@conv_hh,2,4);

        end
        function test_operations(obj)
            % Test pdf_table_array


            % Create random samples from all of the distributions
            % ---------------------------------------------------
            pdf_arr = [obj.pdf_gauss,obj.pdf_hat;obj.pdf_tri,obj.pdf_hh]';
            pdf = pdf_table_array(pdf_arr);

            % Have an index of multiple mixed pdfs:
            nsamp = 1e7;
            ind = floor(numel(pdf_arr)*rand(ceil(nsamp/10),10)) + 1;
            xsamp = rand_ind(pdf,ind);

            wdist_gauss = vals2distr(xsamp(ind==1),obj.x_gauss_bin,'norm','poisson');
            wdist_hat = vals2distr(xsamp(ind==2),obj.x_hat_bin,'norm','poisson');
            wdist_tri = vals2distr(xsamp(ind==3),obj.x_tri_bin,'norm','poisson');
            wdist_hh = vals2distr(xsamp(ind==4),obj.x_hh_bin,'norm','poisson');

            % Compare random sampling from pdf_table_array
            % --------------------------------------------
            % For the comparison with a hat function, we need to handle the
            % discontinuity carefully. Choose x positions that match the distribution
            % constructed from the random sampling above


            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (obj.w_gauss,wdist_gauss,4,'rebin','chi');
            assertTrue(ok,['Gaussian sampling failed ',mess])

            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (obj.w_hat,wdist_hat,4,'rebin','chi');
            assertTrue(ok,['Hat sampling failed ',mess])

            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wdist_tri,obj.w_tri,4,'rebin','chi');
            assertTrue(ok,['Triangle sampling failed ',mess])

            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (wdist_hh,obj.w_hh,4,'rebin','chi');
            assertTrue(ok,['Trapezoid sampling failed ',mess])
        end

        function test_recover_from_property(obj)
            pdf_arr = [obj.pdf_gauss,obj.pdf_hat;obj.pdf_tri,obj.pdf_hh]';
            pdf = pdf_table_array(pdf_arr);

            data = pdf.dist_functions;
            pdf2 = pdf_table_array();

            pdf2.dist_functions = data;

            assertEqual(pdf,pdf2);
        end

        function test_single_table(obj)

            % Have an index of multiple mixed pdfs:
            nsamp = 1e7;

            % Special case of a single table
            % ------------------------------
            % Checks a limiting case

            pdf_single = pdf_table_array(obj.pdf_hh);
            xsamp = rand_ind(pdf_single, ones(1,nsamp));
            w_single = vals2distr(xsamp,obj.x_hh_bin,'norm','poisson');

            [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w_single,obj.w_hh,10,'rebin','chi');
            assertTrue(ok,['Single trapezoid sampling failed ',mess])

        end
        function test_prev_versions(obj)
            % Scalar example
            pdf_arr = [obj.pdf_gauss,obj.pdf_hat;obj.pdf_tri,obj.pdf_hh]';
            pdf = pdf_table_array(pdf_arr);

            sample_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files before changed to new class version
                save_variables=true;
                ver = pdf.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, sample_files_location,pdf);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, sample_files_location ,pdf);
            end
        end

    end
end