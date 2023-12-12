classdef test_parse_pixel_indices < TestCase
    % Test the sqw class method parse_pixel_indices
    properties
        w1
        w2
        irun1
        idet1
        ien1
        irun2
        idet2
        ien2
    end

    methods
        function obj = test_parse_pixel_indices (name)
            obj = obj@TestCase(name);
            
            % Load two tiny sqw objects from file
            %   w1:  29 pixels, two runs, runid: 100, 200 
            %        (runid are 100 x header index)
            %   w2:  18 pixels, three runs, runid: 1000, 2000, 3000 
            %        (runid are 1000 x header index)
            load('test_parse_pixel_indices_data.mat','w1','w2')
            obj.w1 = w1;
            obj.w2 = w2;
            
            obj.irun1 = w1.pix.run_idx(:) / 100;
            obj.idet1 = w1.pix.detector_idx(:); 
            obj.ien1 = w1.pix.energy_idx(:);
            
            obj.irun2 = w2.pix.run_idx(:) / 1000;
            obj.idet2 = w2.pix.detector_idx(:); 
            obj.ien2 = w2.pix.energy_idx(:);
        end
        
        function test_emptySqwObject_ERROR(~)
            % Must be at least one sqw object in the array
            w = repmat(sqw(), 0);   % empty sqw array
            f = @() parse_pixel_indices(w);
            assertExceptionThrown(f, 'HORACE:parse_pixel_indices:invalid_argument');
        end
        
        function test_SqwObject_noPixels(~)
            % Scalar sqw object, but without any pixels: is valid
            w = sqw();
            [irun,idet,ien]=parse_pixel_indices(w);
            assertEqual(irun, zeros(0,1))
            assertEqual(idet, zeros(0,1))
            assertEqual(ien, zeros(0,1))
        end
        
        function test_scalarSqwObject(obj)
            % Scalar sqw object
            w = obj.w1;
            [irun,idet,ien]=parse_pixel_indices(w);
            assertEqual(irun, obj.irun1)
            assertEqual(idet, obj.idet1)
            assertEqual(ien, obj.ien1)
        end
        
        function test_scalarSqwObject_ipixEmpty_ERROR(obj)
            % Scalar sqw object, ipix empty
            w = obj.w1;
            ipix = []; % empty ipix allowed
            f = @() parse_pixel_indices(w, ipix);
            assertExceptionThrown(f, 'HORACE:parse_pixel_indices:invalid_argument');
        end
        
        function test_scalarSqwObject_ipixMultiple_ERROR(obj)
            % Scalar sqw object, two arrays of ipix => error
            w = obj.w1;
            ipix = {[5,6], [14,15,16]};
            f = @() parse_pixel_indices(w, ipix);
            assertExceptionThrown(f, 'HORACE:parse_pixel_indices:invalid_argument');
        end
        
        function test_scalarSqwObject_ipix(obj)
            % Scalar sqw object, ipix
            w = obj.w1;
            ipix = [5,21,3;15,5,7];
            [irun,idet,ien]=parse_pixel_indices(w, ipix);
            irun_ref = reshape(obj.irun1(ipix), size(ipix));
            idet_ref = reshape(obj.idet1(ipix), size(ipix));
            ien_ref = reshape(obj.ien1(ipix), size(ipix));
            assertEqual(irun, irun_ref)
            assertEqual(idet, idet_ref)
            assertEqual(ien, ien_ref)
        end
        
        function test_rowArraySqwObject(obj)
            % Row vector sqw object
            w = [obj.w1, obj.w2];
            [irun,idet,ien]=parse_pixel_indices(w);
            assertTrue(isa(irun,'cell') && isequal(size(irun),[1,2]))
            assertTrue(isa(idet,'cell') && isequal(size(idet),[1,2]))
            assertTrue(isa(ien,'cell') && isequal(size(ien),[1,2]))
            assertEqual(irun{1}, obj.irun1)
            assertEqual(idet{1}, obj.idet1)
            assertEqual(ien{1}, obj.ien1)
            assertEqual(irun{2}, obj.irun2)
            assertEqual(idet{2}, obj.idet2)
            assertEqual(ien{2}, obj.ien2)
        end
        
        function test_rowArraySqwObject_ipixSingle_outOfRange_ERROR(obj)
            % Row vector sqw object; ipix has an out of range pixel number for
            % w2, so should throw an error
            w = [obj.w1, obj.w2];
            ipix = [5,21,3;15,5,7];
            f = @() parse_pixel_indices(w, ipix);
            assertExceptionThrown(f, 'HORACE:parse_pixel_indices:invalid_argument');
        end
        
        function test_rowArraySqwObject_ipixSingle(obj)
            % Row vector sqw object
            w = [obj.w1, obj.w2];
            ipix = [5,13,3;15,5,7];
            [irun,idet,ien]=parse_pixel_indices(w, ipix);
            assertTrue(isa(irun,'cell') && isequal(size(irun),[1,2]))
            assertTrue(isa(idet,'cell') && isequal(size(idet),[1,2]))
            assertTrue(isa(ien,'cell') && isequal(size(ien),[1,2]))
            assertEqual(irun{1}, reshape(obj.irun1(ipix), size(ipix)))
            assertEqual(idet{1}, reshape(obj.idet1(ipix), size(ipix)))
            assertEqual(ien{1}, reshape(obj.ien1(ipix), size(ipix)))
            assertEqual(irun{2}, reshape(obj.irun2(ipix), size(ipix)))
            assertEqual(idet{2}, reshape(obj.idet2(ipix), size(ipix)))
            assertEqual(ien{2}, reshape(obj.ien2(ipix), size(ipix)))
        end
        
        function test_rowArraySqwObject_ipixMultiple(obj)
            % Row vector sqw object
            w = [obj.w1, obj.w2];
            ipix1 = [5,21,3;15,5,7];
            ipix2 = [5,13,3;15,5,7];
            ipix = {ipix1; ipix2};  % column: should be OK as shape wrt w not tested
            [irun,idet,ien]=parse_pixel_indices(w, ipix);
            assertTrue(isa(irun,'cell') && isequal(size(irun),[1,2]))
            assertTrue(isa(idet,'cell') && isequal(size(idet),[1,2]))
            assertTrue(isa(ien,'cell') && isequal(size(ien),[1,2]))
            assertEqual(irun{1}, reshape(obj.irun1(ipix1), size(ipix1)))
            assertEqual(idet{1}, reshape(obj.idet1(ipix1), size(ipix1)))
            assertEqual(ien{1}, reshape(obj.ien1(ipix1), size(ipix1)))
            assertEqual(irun{2}, reshape(obj.irun2(ipix2), size(ipix2)))
            assertEqual(idet{2}, reshape(obj.idet2(ipix2), size(ipix2)))
            assertEqual(ien{2}, reshape(obj.ien2(ipix2), size(ipix2)))
        end
        
        function test_columnArraySqwObject_ipixMultiple(obj)
            % Row vector sqw object
            w = [obj.w1; obj.w2];
            ipix1 = [5,21,3;15,5,7];
            ipix2 = [5,13,3;15,5,7];
            ipix = {ipix1; ipix2};
            [irun,idet,ien]=parse_pixel_indices(w, ipix);
            assertTrue(isa(irun,'cell') && isequal(size(irun),[2,1]))
            assertTrue(isa(idet,'cell') && isequal(size(idet),[2,1]))
            assertTrue(isa(ien,'cell') && isequal(size(ien),[2,1]))
            assertEqual(irun{1}, reshape(obj.irun1(ipix1), size(ipix1)))
            assertEqual(idet{1}, reshape(obj.idet1(ipix1), size(ipix1)))
            assertEqual(ien{1}, reshape(obj.ien1(ipix1), size(ipix1)))
            assertEqual(irun{2}, reshape(obj.irun2(ipix2), size(ipix2)))
            assertEqual(idet{2}, reshape(obj.idet2(ipix2), size(ipix2)))
            assertEqual(ien{2}, reshape(obj.ien2(ipix2), size(ipix2)))
        end
        
    end
end
