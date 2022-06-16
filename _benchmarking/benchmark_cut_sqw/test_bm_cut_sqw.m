classdef test_bm_cut_sqw < TestCase
    %TEST_CUT_SQW 
        
    properties 
        working_dir;
        sqw_file_small;
        sqw_file_medium;
        sqw_file_large;
        dnd_file_small;
        dnd_file_medium;
        dnd_file_large;
        proj;
        bm_cut_sqw_profile_file;
    end
    
    methods

        function obj = test_bm_cut_sqw(test_class_name)
            %The constructor cut_sqw class

            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_cut_sqw';
            end

            obj = obj@TestCase(test_class_name);
            obj.working_dir = tmp_dir;

            common_data = fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'common_data');
            obj.sqw_file_small=fullfile(common_data,'fe_demo_small.sqw');
            obj.sqw_file_medium=fullfile(common_data,'fe_demo_medium.sqw');
            obj.sqw_file_large=fullfile(common_data,'fe_demo_large.sqw');
            obj.proj.u=[1,0,0]; obj.proj.v=[0,1,0]; obj.proj.type='rrr';
            obj.bm_cut_sqw_profile_file=fullfile(common_data,'bm_cut_sqw_profile.txt');
        end
        
        function test_bm_cut_sqw_3D_sqw_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_largeEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220],'-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200],'-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,190]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,190],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_smallEnergy_np1(obj)
            maxNumCompThreads(1);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,190], '-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,700],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,400],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_largeEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220],'-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,500],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,300],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200],'-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[180,200],'-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3]...
                ,[-0.1,0.1],[0,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9]...
                ,[-0.1,0.1],[100,16,150]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190], '-nopix');           
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_smallEnergy_np2(obj)
            maxNumCompThreads(2);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190], '-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,700], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,400], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_largeEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220], '-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,200]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,220]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,500], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,300], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,200], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,200], '-nopix');
        end

        function test_bm_cut_sqw_3D_sqw_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_small,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_medium,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300]);
        end

        function test_bm_cut_sqw_3D_sqw_largeData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300]);
        end

        function test_bm_cut_sqw_2D_sqw_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150]);
        end

        function test_bm_cut_sqw_2D_sqw_largeData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150]);
        end

        function test_bm_cut_sqw_1D_sqw_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_small,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_1D_sqw_largeData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190]);
        end

        function test_bm_cut_sqw_3D_dnd_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_3D_dnd_largeData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc3=cut_sqw(obj.sqw_file_large,obj.proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],...
                [0,16,300], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_2D_dnd_largeData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc2=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [100,16,150], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_smallData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190], '-nopix');
        end

        function test_bm_cut_sqw_1D_dnd_mediumData_smallEnergy_np4(obj)
            maxNumCompThreads(4);
            cc1=cut_sqw(obj.sqw_file_large,obj.proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],...
                [180,190], '-nopix');
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_2D_sqw_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc2=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[100,16,400]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_smallData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_smallData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_smallData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_small,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_mediumData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_mediumData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_mediumData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_medium,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_largeData_mediumEnergy_np1(obj)
            maxNumCompThreads(1);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_largeData_mediumEnergy_np2(obj)
            maxNumCompThreads(2);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end

        function test_bm_cut_sqw_contiguous_1D_sqw_largeData_mediumEnergy_np4(obj)
            maxNumCompThreads(4);
            for i=-2:9
                cc1=cut_sqw(obj.sqw_file_large,obj.proj,[i-3,0.05,i],...
                    [-2.1,-1.9],[-0.1,0.1],[180,190]);
            end
        end
    end
end