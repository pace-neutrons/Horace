classdef test_pdf_table_lookup < TestCaseWithSave
    properties
        c1
        c2a
        c2b
        c3
        c4
        c5

        home_folder
    end

    methods
        function obj= test_pdf_table_lookup(varargin)
            home_folder = fileparts(mfilename('fullpath'));
            if nargin == 0
                name = 'test_pdf_table_lookup';
            else
                name = varargin{1};
            end

            %--------------------------------------------------------------------------
            % Create some Fermi chopper objects
            % ---------------------------------
            file = fullfile(home_folder,'test_pdf_table_lookup_output.mat');
            obj@TestCaseWithSave(name,file);
            obj.home_folder = home_folder;


            obj.c1=IX_fermi_chopper(10,150,0.049,1.3,0.003,Inf, 0, 0,50);
            obj.c2a=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,100);
            obj.c2b=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,120);     % differs in column index >1 from c2a
            obj.c3=IX_fermi_chopper(10,350,0.049,1.3,0.003,Inf, 0, 0,300);
            obj.c4=IX_fermi_chopper(10,450,0.049,1.3,0.003,Inf, 0, 0,400);
            obj.c5=IX_fermi_chopper(10,550,0.049,1.3,0.003,Inf, 0, 0,350);

            obj.save();
        end

        function test_lookup_table(obj)
            hc = herbert_config;
            log_level = hc.log_level;


            [y,t] = pulse_shape(obj.c1);  ww1=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(obj.c2a); ww2=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(obj.c3);  ww3=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(obj.c4);  ww4=IX_dataset_1d(t,y);
            %[y,t] = pulse_shape(obj.c5);  ww5=IX_dataset_1d(t,y);

            ww1 = ww1/obj.c1.transmission();    % normalised to unit integral
            ww2 = ww2/obj.c2a.transmission();
            ww3 = ww3/obj.c3.transmission();
            ww4 = ww4/obj.c4.transmission();
            %ww5 = ww5/obj.c5.transmission();


            %--------------------------------------------------------------------------
            % Test the lookup table
            % ----------------------

            arr1 = [obj.c2a,obj.c1,obj.c4,obj.c1,obj.c1,obj.c2a];
            arr2 = [...
                obj.c4, obj.c3, obj.c3;...
                obj.c2a,obj.c1, obj.c3];
            arr3 = [obj.c3,obj.c1];

            lookup = pdf_table_lookup({arr1,arr2,arr3});

            %----------
            % Test:
            %----------
            w1_ref = [ww2,ww1,ww4,ww1,ww1,ww2];
            w2_ref = [ww4,ww2,ww3,ww1,ww3,ww3];
            w3_ref = [ww3,ww1];


            %----------
            nsamp = 1e7;
            ind1 = floor(numel(arr1)*rand(ceil(nsamp/10),10)) + 1;
            xsamp1 = rand_ind(lookup,1,ind1);

            w1samp(1) = vals2distr(xsamp1(ind1==1),'norm','poisson');
            w1samp(2) = vals2distr(xsamp1(ind1==2),'norm','poisson');
            w1samp(3) = vals2distr(xsamp1(ind1==3),'norm','poisson');
            w1samp(4) = vals2distr(xsamp1(ind1==4),'norm','poisson');
            w1samp(5) = vals2distr(xsamp1(ind1==5),'norm','poisson');
            w1samp(6) = vals2distr(xsamp1(ind1==6),'norm','poisson');

            if log_level>0, disp('-----------------'), end
            for i=1:numel(w1samp)
                [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w1_ref(i),w1samp(i),3,'rebin','chi');
                if log_level>0
                    if ~ok
                        disp([i,chisqr])
                        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
                    else
                        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
                    end
                end
                assertTrue(ok,mess);
            end

            %----------
            nsamp = 1e7;
            ind2 = floor(numel(arr2)*rand(ceil(nsamp/10),10)) + 1;
            xsamp2 = rand_ind(lookup,2,ind2);

            w2samp(1) = vals2distr(xsamp2(ind2==1),'norm','poisson');
            w2samp(2) = vals2distr(xsamp2(ind2==2),'norm','poisson');
            w2samp(3) = vals2distr(xsamp2(ind2==3),'norm','poisson');
            w2samp(4) = vals2distr(xsamp2(ind2==4),'norm','poisson');
            w2samp(5) = vals2distr(xsamp2(ind2==5),'norm','poisson');
            w2samp(6) = vals2distr(xsamp2(ind2==6),'norm','poisson');

            if log_level>0, disp('-----------------'), end
            for i=1:numel(w2samp)
                [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w2_ref(i),w2samp(i),3,'rebin','chi');
                if log_level>0
                    if ~ok
                        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
                    else
                        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
                    end
                end
                assertTrue(ok,mess);
            end

            %----------
            nsamp = 1e7;
            ind3 = floor(numel(arr3)*rand(ceil(nsamp/10),10)) + 1;
            xsamp3 = rand_ind(lookup,3,ind3);

            w3samp(1) = vals2distr(xsamp3(ind3==1),'norm','poisson');
            w3samp(2) = vals2distr(xsamp3(ind3==2),'norm','poisson');

            if log_level>0, disp('-----------------'), end
            for i=1:numel(w3samp)
                [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w3_ref(i),w3samp(i),3,'rebin','chi');
                if log_level>0
                    if ~ok
                        disp(['Dataset ',num2str(i),' BAD (chisqr = ',num2str(chisqr),') **********'])
                    else
                        disp(['Dataset ',num2str(i),' chisqr = ',num2str(chisqr)])
                    end
                end
                assertTrue(ok,mess);
            end
        end

        function test_sort_obj(obj)
            % Check sort
            carr1=[obj.c5,obj.c3,obj.c2b,obj.c1,obj.c2a,obj.c4];

            [csort1,ix]=sortObj(carr1);
            assertTrue(isequal(ix,[4,5,3,2,6,1]))
            assertTrue(isequal(carr1(ix),csort1))
        end
        function test_unique(obj)
            % Check unique
            carr2=[obj.c5,obj.c2b,obj.c3,obj.c5,obj.c2b,obj.c1,obj.c4,obj.c2a,obj.c4];

            [csort2,ix,ib]=uniqueObj(carr2,'last');

            assertTrue(isequal(ix',[6     8     5     3     9     4]));
            assertTrue(isequal(ib',[6     3     4     6     3     1     5     2     5]));
            assertTrue(isequal(carr2(ix),csort2));
            assertTrue(isequal(carr2,csort2(ib)));
        end
        function test_unique_in_reverse(obj)

            % Check unique in reverse
            carr2=[obj.c5,obj.c2b,obj.c3,obj.c5,obj.c2b,obj.c1,obj.c4,obj.c2a,obj.c4];

            [csort2,ix,ib]=uniqueObj(carr2,'first');
            assertTrue(isequal(ix',[6     8     2     3     7     1]));
            assertTrue(isequal(ib',[6     3     4     6     3     1     5     2     5]));
            assertTrue(isequal(carr2(ix),csort2));
            assertTrue(isequal(carr2,csort2(ib)));
        end

        function test_prev_versions_IO(obj)
            arr1 = [obj.c2a,obj.c1,obj.c4,obj.c1,obj.c1,obj.c2a];
            arr2 = [...
                obj.c4, obj.c3, obj.c3;...
                obj.c2a,obj.c1, obj.c3];
            arr3 = [obj.c3,obj.c1];

            lookup = pdf_table_lookup({arr1,arr2,arr3});
            % check current version
            assertEqualWithSave(obj,lookup)

            lookup_files_location = obj.home_folder;
            if obj.save_output
                % run test_IX_apperture with -save option to obtain reference
                % files when changed to new class version
                save_variables=true;
                ver = lookup.classVersion();
                verstr = ['ver',num2str(ver)];
                check_matfile_IO(verstr, save_variables, lookup_files_location ,lookup);

            else
                save_variables=false;

                verstr= 'ver1';
                check_matfile_IO(verstr, save_variables, lookup_files_location  ,lookup);
            end
        end

    end
end