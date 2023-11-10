classdef test_sqw_save_xye < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        det_dir = fileparts(fileparts(mfilename('fullpath')));
        sample_files
    end

    methods

        function obj = test_sqw_save_xye(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_sqw_save_xye';
            end
            obj = obj@TestCase(name);
            det_file = fullfile(obj.det_dir,'common_data','96dets.par');
            params = {1:10,det_file,'',11,1,[2.8,2.8,2.8],[90,90,90],...
                [1,0,0],[0,1,0],10, 0, 0, 0, 0};
            sqw_4d_samp = dummy_sqw(params{:},[5,5,5,5]);
            sqw_4d_samp  = sqw_4d_samp{1};
            obj.sample_files{1} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[-1,1],[-1,1],[0,10]);
            obj.sample_files{2} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[],[-1,1],[0,10]);
            obj.sample_files{3} = cut_sqw(sqw_4d_samp,...
                struct('u',[1,0,0],'v',[0,1,0]),[],[],[],[0,10]);
            obj.sample_files{4} = sqw_4d_samp;
        end
        function [count,cont] = read_file(~,filename)
            fh = fopen(filename);
            assertTrue(fh>0);
            clob = onCleanup(@()fclose(fh));
            count = 0;
            lin1 = fgetl(fh);
            cont{1} = lin1;
            while lin1>0
                count = count +1;
                lin1 = fgetl(fh);
                cont{end+1} = lin1;
            end

        end
        function test_save_xye_4d(obj)
            % save sqw
            sqw_samp = obj.sample_files{4};
            test_file1 = fullfile(obj.out_dir,'test_save_xye_4d_sqw.txt');
            clob1 = onCleanup(@()delete(test_file1));
            save_xye(sqw_samp,test_file1)
            assertEqual(exist(test_file1,'file'),2);
            % Save d1d
            test_file2 = fullfile(obj.out_dir,'test_save_xye_4d_d4d.txt');
            clob2 = onCleanup(@()delete(test_file2));
            save_xye(d4d(sqw_samp),test_file2)
            assertEqual(exist(test_file2,'file'),2);

            [count1,cont1] = obj.read_file(test_file1);
            assertEqual(count1,625);
            [count2,cont2] = obj.read_file(test_file2);
            assertEqual(count2,625);

            assertEqual([cont1{:}],[cont2{:}]);
        end

        function test_save_xye_3d(obj)
            % save sqw
            sqw_samp = obj.sample_files{3};
            test_file1 = fullfile(obj.out_dir,'test_save_xye_3d_sqw.txt');
            clob1 = onCleanup(@()delete(test_file1));
            save_xye(sqw_samp,test_file1)
            assertEqual(exist(test_file1,'file'),2);
            % Save d1d
            test_file2 = fullfile(obj.out_dir,'test_save_xye_3d_d3d.txt');
            clob2 = onCleanup(@()delete(test_file2));
            save_xye(d3d(sqw_samp),test_file2)
            assertEqual(exist(test_file2,'file'),2);

            [count1,cont1] = obj.read_file(test_file1);
            assertEqual(count1,numel(sqw_samp.data.npix));
            [count2,cont2] = obj.read_file(test_file2);
            assertEqual(count2,numel(sqw_samp.data.npix));

            assertEqual([cont1{:}],[cont2{:}]);
        end

        function test_save_xye_2d(obj)
            % save sqw
            sqw_samp = obj.sample_files{2};
            test_file1 = fullfile(obj.out_dir,'test_save_xye_2d_sqw.txt');
            clob1 = onCleanup(@()delete(test_file1));
            save_xye(sqw_samp,test_file1)
            assertEqual(exist(test_file1,'file'),2);
            % Save d1d
            test_file2 = fullfile(obj.out_dir,'test_save_xye_2d_d2d.txt');
            clob2 = onCleanup(@()delete(test_file2));
            save_xye(d2d(sqw_samp),test_file2)
            assertEqual(exist(test_file2,'file'),2);

            [count1,cont1] = obj.read_file(test_file1);
            assertEqual(count1,numel(sqw_samp.data.s));
            [count2,cont2] = obj.read_file(test_file2);
            assertEqual(count2,numel(sqw_samp.data.s));

            assertEqual([cont1{:}],[cont2{:}]);
        end

        function test_save_xye_1d(obj)
            % save sqw
            sqw_samp = obj.sample_files{1};
            test_file1 = fullfile(obj.out_dir,'test_save_xye_1d_sqw.txt');
            clob1 = onCleanup(@()delete(test_file1));
            save_xye(sqw_samp,test_file1)
            assertEqual(exist(test_file1,'file'),2);
            % Save d1d
            test_file2 = fullfile(obj.out_dir,'test_save_xye_1d_d1d.txt');
            clob2 = onCleanup(@()delete(test_file2));
            save_xye(d1d(sqw_samp),test_file2)
            assertEqual(exist(test_file2,'file'),2);

            [count1,cont1] = obj.read_file(test_file1);
            assertEqual(count1,5);
            [count2,cont2] = obj.read_file(test_file2);
            assertEqual(count2,5);

            assertEqual([cont1{:}],[cont2{:}]);
        end

    end
end
