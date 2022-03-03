classdef test_replicate< TestCase
    %
    % Validate sqw object replication


    properties
        this_dir;
        sqw_3D_artificial
    end

    methods

        %The above can now be read into the test routine directly.
        function obj=test_replicate(name)
            if ~exist('name','var')
                name = 'test_replicate_sqw';
            end
            obj=obj@TestCase(name);
            obj.this_dir = fileparts(mfilename('fullpath'));
            en = -5:1:80;
            efix = 85;
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            k_range = [-1,0.1,1;-1,0.1,1;-1,0.1,1];
            wtmp = fake_sqw(en,k_range,'',efix,1,...
                alatt,angdeg,[1,0,0],[0,1,0],0,0,0,0,0,[50,50,50,50]);
            function sig = signal(h,k,l,en,p)
                sig = ones(size(h))*p(1);
            end

            obj.sqw_3D_artificial = sqw_eval(wtmp{1},@signal,{1});

        end

        % tests
        function test_replicate_1Dto3D(obj)

            w1 = cut(obj.sqw_3D_artificial,[-1,0.02,1],[-1,1],[-0.1,0.1],[-0.5,0.5]);
            w2 = cut(obj.sqw_3D_artificial,[-1,0.02,1],[-1,1],[-1,0.02,1],[-0.5,0.5]);            

            d2r = replicate(w1,w2);

            %assertEqual(d2r,dnd(w2));
            assertTrue(isa(d2r,'d2d'))
            assertEqual(w2.data.p{1},d2r.p{1})
            assertEqual(w2.data.p{2},d2r.p{2})            
        end
    end
end


