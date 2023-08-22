classdef test_tobyfit_lookup < TestCase
    % Test of fitting moderator with Tobyfit
    
    properties

    end
    
    methods
        function obj = test_tobyfit_lookup (name)

            if nargin == 0
                name = 'test_tobyfit_lookup';
            end
            obj = obj@TestCase(name);
        end
        
                
        function obj = test_basic_functionality(obj)

            % testing object_lookup from various initialisations
            
            % test data set is four IX_samples
            sample1 = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);
            sample2 = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);            
            sample3 = IX_sample(true,[1,0,0],[0,0,1],'cuboid',[0.04,0.03,0.02],[6,0,4]);      
            sample4 = IX_sample(true,[0,0,1],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);              
            sample1.name = '111';
            sample2.name = '222';
            sample3.name = '333';
            sample4.name = '444';
            
            % assemble then combine into 
            % A a unique_objects_container samplesA, and
            % X an array samplesX
            
            samplesA = unique_objects_container('IX_samp');
            samplesA = samplesA.add(sample1);
            samplesA = samplesA.add(sample2);
            samplesA = samplesA.add(sample3);
            samplesA = samplesA.add(sample4);
            assertEqual(samplesA.n_runs, 4);
            assertEqual(samplesA.n_unique, 4);
            
            samplesX = [sample1 sample2 sample3 sample4];
            
            % repeat with a different combination into
            % B a unique_objects_container samplesB and
            % Y an array samplesY
            
            samplesB = unique_objects_container('IX_samp');
            samplesB = samplesB.add(sample2);
            samplesB = samplesB.add(sample2);
            samplesB = samplesB.add(sample4);
            samplesB = samplesB.add(sample3);
            assertEqual(samplesB.n_runs, 4);
            assertEqual(samplesB.n_unique, 3);
            
            samplesY = [sample2 sample2 sample4 sample3];
            
            % repeat again with yet another combination into
            % (which is currently the same, but tests something about
            % maximum duplicate removal
            % samplesC = unique_objects_container
            % samplesZ = array
            
            samplesC = unique_objects_container('IX_samp');
            samplesC = samplesC.add(sample2);
            samplesC = samplesC.add(sample2);
            samplesC = samplesC.add(sample4);
            samplesC = samplesC.add(sample3);
            assertEqual(samplesC.n_runs, 4);
            assertEqual(samplesC.n_unique, 3);
            
            samplesZ = [sample2 sample2 sample4 sample3];
            
            % put the array collections into a cell and make an
            % object_lookup from it
            samplesXYZ = {samplesX samplesY samplesZ};
            lookupXYZ = object_lookup(samplesXYZ);
            
            % put the unique_object_containers into a cell and make an
            % object_lookup from it
            samplesABC = [samplesA samplesB samplesC];
            lookupABC = object_lookup(samplesABC);
            
            % compare the unique_objects_container and array versions of
            % object_lookup. They should be identical. However the
            % compression methods of the two containers yields different
            % orders, so both containers are sorted internally to the same
            % order before the comparison.
            
            XYZ = lookupXYZ.sort();
            ABC = lookupABC.sort();
            assertEqual( XYZ, ABC );
            
            % additional tests using one set of objects
            % and initialising as single objects (array or
            % unique_object_container) and as cell arrays of the preceding
            % (exercises different code paths through the object_lookup
            % constructor)
            N = object_lookup(samplesA);
            P = object_lookup({samplesA});
            Q = object_lookup(samplesX);
            R = object_lookup({samplesX});
            ns = N.sort();
            ps = P.sort();
            qs = Q.sort();
            rs = R.sort();
            % compare array and cell array inputs for same object type
            % (sort not needed as same object type)
            assertEqual(N,P);
            assertEqual(Q,R);
            % compare array and unique_object_container inputs with and
            % without cell array conversion (requires sort)
            assertEqual(ns,qs);
            assertEqual(ps,rs);
        end
        
        
    end
end