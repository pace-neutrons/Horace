classdef test_combine< TestCase
    %
    % Validate the dnd symmetrisation, combination and rebin routines
    
    
    %% Copied from template in test_multifit_horace_1
    properties
        %What we actually want to do is to simulate some cross-section that is
        %symmetric so that we can compare results easily.
        stiffness=80;
        gam=0.1;
        amp=10;
        testdir;
    end
    
    
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_combine(name)
            
            this=this@TestCase(name);
            this.testdir = fileparts(mfilename('fullpath'));
            
        end
        function delete(this)
            close all;
        end
        
        function this=prepare_test_data(this)
        
        %% Use sqw file on RAE's laptop to perform tests. Data saved to a .mat file on SVN server for validation by others.
        data_source='C:\Russell\PCMO\ARCS_Oct10\Data\SQW\ei140.sqw';
        proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';
        
        
        %To ensure some of the catches for dnd symmetrisation work properly, need
        %to add some errorbars to all of the data points as well. Take from the
        %original data. Errorbars are rescaled to be appropriate size for new
        %signal array
        
        %2d
        w2d_qq_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[30,40]);
        w2d_qq_sqw=sqw_eval(w2d_qq_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
        errs=w2d_qq_sqw.data.pix(8,:);
        w2d_qq_sqw.data.pix(9,:)=errs;
        w2d_qq_sqw=cut(w2d_qq_sqw,[-1,0.025,1],[-1,0.025,1]);
        w2d_qq_d2d=d2d(w2d_qq_sqw);

        w2d_qq_sqw_plus=cut(w2d_qq_sqw,[-1,0.025,1],[0,0.025,1]);
        w2d_qq_d2d_plus=d2d(w2d_qq_sqw_plus);
        
        w2d_qq_sqw_minus=cut(w2d_qq_sqw,[-1,0.025,1],[-1,0.025,0]);
        w2d_qq_d2d_minus=d2d(w2d_qq_sqw_minus);
        
        %1d
        w1d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[30,40]);
        w1d_sqw=sqw_eval(w1d_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
        errs=w1d_sqw.data.pix(8,:);
        w1d_sqw.data.pix(9,:)=errs;
        w1d_sqw=cut(w1d_sqw,[-1,0.025,1]);
        w1d_d1d=d1d(w1d_sqw);
        
        w1d_sqw_minus=cut(w1d_sqw,[-1,0.025,0]);
        w1d_d1d_minus=d1d(w1d_sqw_minus);
        
        w1d_sqw_plus=cut(w1d_sqw,[0,0.025,1]);
        w1d_d1d_plus=d1d(w1d_sqw_plus);
        
        
        save(w2d_qq_sqw,[this.testdir,filesep,'w2d_qq_sqw.sqw']);
        save(w2d_qq_sqw_minus,[this.testdir,filesep,'w2d_qq_sqw_minus.sqw']);
        save(w2d_qq_sqw_plus,[this.testdir,filesep,'w2d_qq_sqw_plus.sqw']);
        
        save(w2d_qq_d2d,[this.testdir,filesep,'w2d_qq_d2d.sqw']);
        save(w2d_qq_d2d_minus,[this.testdir,filesep,'w2d_qq_d2d_minus.sqw']);
        save(w2d_qq_d2d_plus,[this.testdir,filesep,'w2d_qq_d2d_plus.sqw']);
        
        save(w1d_sqw,[this.testdir,filesep,'w1d_sqw.sqw']);
        save(w1d_sqw_minus,[this.testdir,filesep,'w1d_sqw_minus.sqw']);
        save(w1d_sqw_plus,[this.testdir,filesep,'w1d_sqw_plus.sqw']);
        
        save(w1d_d1d,[this.testdir,filesep,'w1d_d1d.sqw']);
        save(w1d_d1d_minus,[this.testdir,filesep,'w1d_d1d_minus.sqw']);
        save(w1d_d1d_plus,[this.testdir,filesep,'w1d_d1d_plus.sqw']);
       
        
        end
        %% Combine data tests
        function this = test_combine_sqw(this)
            %sqw combination
            w2d_qq_sqw=read_sqw(fullfile(this.testdir,'w2d_qq_sqw.sqw'));
            w2d_qq_sqw_plus=read_sqw(fullfile(this.testdir,'w2d_qq_sqw_plus.sqw'));
            w2d_qq_sqw_minus=read_sqw(fullfile(this.testdir,'w2d_qq_sqw_minus.sqw'));
            
            %NB - combining results in slightly different binning and pix
            w2d_qq_combined=combine_sqw(w2d_qq_sqw_minus,w2d_qq_sqw_plus);
            
            [wfit_qq,fitdata_qq]=fit_sqw(w2d_qq_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            [wfit_combi,fitdata_combi]=fit_sqw(w2d_qq_combined,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            
            [ok,mess]=equal_to_tol(fitdata_qq.p,fitdata_combi.p,-1e-6,'ignore_str', 1);
            assertTrue(ok,['combine sqw fails: ',mess])
        end
        
        function this = test_combine_dnd_notol(this)
            %dnd combination without specifying a tolerance
            w2d_qq_d2d=read_dnd(fullfile(this.testdir,'w2d_qq_d2d.sqw'));
            w2d_qq_d2d_plus=read_dnd(fullfile(this.testdir,'w2d_qq_d2d_plus.sqw'));
            w2d_qq_d2d_minus=read_dnd(fullfile(this.testdir,'w2d_qq_d2d_minus.sqw'));
            
            w2d_qq_combined=combine_horace_2d(w2d_qq_d2d_minus,w2d_qq_d2d_plus);
            
            [wfit_qq,fitdata_qq]=fit_sqw(w2d_qq_d2d,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            [wfit_combi,fitdata_combi]=fit_sqw(w2d_qq_combined,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            
            [ok,mess]=equal_to_tol(fitdata_qq.p,fitdata_combi.p,-2.2e-2,'ignore_str', 1);
            assertTrue(ok,['combine dnd without a specified tolerance fails: ',mess])
            
        end
        
        function this = test_combine_dnd_tol(this)
            %dnd combination specifying a tolerance
            w1d_d1d=read_dnd(fullfile(this.testdir,'w1d_d1d.sqw'));
            w1d_d1d_plus=read_dnd(fullfile(this.testdir,'w1d_d1d_plus.sqw'));
            w1d_d1d_minus=read_dnd(fullfile(this.testdir,'w1d_d1d_minus.sqw'));
            
            w1d_combined=combine_horace_1d(w1d_d1d_minus,w1d_d1d_plus,0.025);
            
            [wfit,fitdata]=fit_sqw(w1d_d1d,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            [wfit_combi,fitdata_combi]=fit_sqw(w1d_combined,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            
            [ok,mess]=equal_to_tol(fitdata.p,fitdata_combi.p,-1.89e-2,'ignore_str', 1);
            assertTrue(ok,['combine dnd with a specified tolerance fails: ',mess])
            
        end
        
       
        
        
    end
end




