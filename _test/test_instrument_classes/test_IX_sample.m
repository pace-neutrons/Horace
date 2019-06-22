classdef test_IX_sample < TestCaseWithSave
    % Test of obj2struct
    properties
        sam1
        sam2
        sam3
        s1
        s2
        s3
        slookup
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_sample (name)
            self@TestCaseWithSave(name);
            
            % Make some samples and sample arrays
            self.sam1 = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            self.sam2 = IX_sample ([0,1,0],[0,0,1],'cuboid',[12,13,34]);
            self.sam3 = IX_sample ([1,1,0],[0,0,1],'cuboid',[22,23,24]);

            self.s1 = [self.sam1, self.sam1, self.sam2, self.sam2, self.sam2];
            self.s2 = [self.sam3, self.sam1, self.sam2, self.sam3, self.sam1];
            self.s3 = [self.sam2, self.sam3, self.sam1, self.sam2, self.sam3];
            
            self.slookup = object_lookup({self.s1, self.s2, self.s3});
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_covariance (self)
            cov = s.func_eval(2,[2,2,1,4,3],@covariance);
            assertEqualWithSave (self,cov);            
        end
        
        %--------------------------------------------------------------------------
        function test_pdf (self)
            nsamp = 1e7;
            ind = randselection([2,3],[ceil(nsamp/10),10]);     % random indicies from 2 and 3
            samp = rand_ind(self.slookup,2,ind);
            samp2 = samp(:,ind==2);
            samp3 = samp(:,ind==3);
            
            
            mean2 = mean(samp2,2);
            mean3 = mean(samp3,2);
            std2 = std(samp2,1,2);
            std3 = std(samp3,1,2);
            
            assertEqualToTol(mean2, [0;0;0], 'tol', 0.001);
            assertEqualToTol(mean3, [0;0;0], 'tol', 0.001);
                        
        end
        
        %--------------------------------------------------------------------------
    end
end

