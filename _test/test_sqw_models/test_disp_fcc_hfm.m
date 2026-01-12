classdef test_disp_fcc_hfm < TestCase
    % Test fcc Heisenberg ferromagnet dispersion relation disp_fcc_hfm
    %
    % Tests that the symmetry of the contributions from each site degeneracy
    % type is respected, by testing for equality of the excitation energy at
    % every symmetry equivalent wavevector of a given wavevector, and about
    % several lattice gamma points.
    %
    % This is done by testing the contribution from each of the first 15
    % neighbours, which collectively cover the contributions from the six
    % different cases of site symmetry (with site degeneracy M):
    %   [x 0 0]     M = 6
    %   [x x 0]     M = 12
    %   [x x x]     M = 8
    %   [x y 0]     M = 24
    %   [x x z]     M = 24
    %   [x y z]     M = 48
    % 
    % and for each of the first 15 neighbours, check for the six different
    % symmetries of wavevector:
    %
    %   Q_h00 = [h,0,0];      6-fold
    %   Q_hh0 = [h,h,0];      12-fold
    %   Q_hhh = [h,h,h];      8-fold
    %   Q_hk0 = [h,k,0];      24-fold
    %   Q_hhk = [h,h,k];      24-fold
    %   Q_hkl = [h,k,l];      48-fold
    %
    % In addition, the excitation energies are tested for equality against
    % stored values to confirm the absolute values, not just the symmetry.

    properties
        Seff
        gap
        par0
        JS
        qh_ref
        qk_ref
        ql_ref
        w_JS
        w_tot
        Qh
        Qk
        Ql
        tol
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_disp_fcc_hfm(name)
            obj = obj@TestCase(name);
            
            % Create sets of symmetry related points in reciprocal space
            qh_ref = 0.216;
            qk_ref = 0.314;
            ql_ref = 0.271;
            
            rlp = [0,0,0; 3,1,5; -2,2,4];
            
            Q_h00 = QsymRelated (qh_ref, 0, 0, rlp);
            Q_hh0 = QsymRelated (qh_ref, qh_ref, 0, rlp);
            Q_hhh = QsymRelated (qh_ref, qh_ref, qh_ref, rlp);
            Q_hk0 = QsymRelated (qh_ref, qk_ref, 0, rlp);
            Q_hhk = QsymRelated (qh_ref, qh_ref, qk_ref, rlp);
            Q_hkl = QsymRelated (qh_ref, qk_ref, ql_ref, rlp);

            obj.qh_ref = qh_ref;
            obj.qk_ref = qk_ref;
            obj.ql_ref = ql_ref;
            obj.Qh = {Q_h00(:,1), Q_hh0(:,1), Q_hhh(:,1), Q_hk0(:,1), Q_hhk(:,1), Q_hkl(:,1)};
            obj.Qk = {Q_h00(:,2), Q_hh0(:,2), Q_hhh(:,2), Q_hk0(:,2), Q_hhk(:,2), Q_hkl(:,2)};
            obj.Ql = {Q_h00(:,3), Q_hh0(:,3), Q_hhh(:,3), Q_hk0(:,3), Q_hhk(:,3), Q_hkl(:,3)};
            
            % Some random exchange parameters and corresponding excitation
            % energies for each exchange parameter individually at [qh_ref, qk_ref, ql_ref]
            obj.Seff = 10;
            obj.gap = 3.94;
            obj.JS = [0.762368339977811   0.080068138934902   0.938246224630109 ...
                0.974473843479017   0.607110428021082   0.957494958695934 ...
                0.330650541159530   0.901215142217029   0.000365623763306 ...
                0.483280019453646   0.147474747267827   0.314992086852311 ...
                0.171375458208079   0.592906936782863   0.657608011954500];

            obj.w_JS = [5.166073062143445    0.530200153173490   23.870445966181734 ...
                11.925126598208013   22.010263997136050    7.576340323959727 ...
                15.162957213294591   10.037988244073540    0.011996036719715 ...
                2.643096671642505    3.189414638890848     7.636762446438667 ...
                4.040913686864440    17.654798298519786    17.676886641695624];
            obj.w_tot = 1.530732639789422e+02;      % energy with all parameters set

            % Initial parameters argument for dispersion relation evaluation
            % All zero, except for the spectral weight
            % In general, par0 contains [Seff, gap, JS1, JS2,...JS15]
            obj.par0 = [obj.Seff, zeros(1,16)];

            % Acceptable absolute and tolerance criterion
            obj.tol = [1e-12, 1e-12];
        end
        
        %--------------------------------------------------------------------------
        function test_gap (obj)
            % Gap only
            par = [obj.Seff, obj.gap];
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(w{1}(1), obj.gap, obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end
        end
        
        %--------------------------------------------------------------------------
        function test_JS1 (obj)
            % Test JS1 only
            par = obj.par0;
            par(3) = obj.JS(1);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS2 (obj)
            % Test JS2 only
            par = obj.par0;
            par(4) = obj.JS(2);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS3 (obj)
            % Test JS3 only
            par = obj.par0;
            par(5) = obj.JS(3);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS4 (obj)
            % Test JS4 only
            par = obj.par0;
            par(6) = obj.JS(4);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS5 (obj)
            % Test JS5 only
            par = obj.par0;
            par(7) = obj.JS(5);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS6 (obj)
            % Test JS6 only
            par = obj.par0;
            par(8) = obj.JS(6);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS7 (obj)
            % Test JS7 only
            par = obj.par0;
            par(9) = obj.JS(7);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS8 (obj)
            % Test JS8 only
            par = obj.par0;
            par(10) = obj.JS(8);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS9 (obj)
            % Test JS9 only
            par = obj.par0;
            par(11) = obj.JS(9);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS10 (obj)
            % Test JS10 only
            par = obj.par0;
            par(12) = obj.JS(10);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS11 (obj)
            % Test JS11 only
            par = obj.par0;
            par(13) = obj.JS(11);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS12 (obj)
            % Test JS12 only
            par = obj.par0;
            par(14) = obj.JS(12);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS13 (obj)
            % Test JS13 only
            par = obj.par0;
            par(15) = obj.JS(13);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS14 (obj)
            % Test JS14 only
            par = obj.par0;
            par(16) = obj.JS(14);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS15 (obj)
            % Test JS15 only
            par = obj.par0;
            par(17) = obj.JS(15);
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS1_to_JS15 (obj)
            % Test JS1 to JS15 all non-zero
            par = obj.par0;
            par(3:17) = obj.JS;
            for i=1:numel(obj.Qh)
                [w, wt] = disp_fcc_hfm(obj.Qh{i}, obj.Qk{i}, obj.Ql{i}, par);
                assertTrue(w{1}(1)>0, 'energy must be greater than zero')
                assertEqualToTol(w{1}, repmat(w{1}(1), size(w{1})), obj.tol);
                assertEqualToTol(wt{1}, repmat(obj.Seff/2, size(wt{1})), obj.tol);
            end

        end
        
        %--------------------------------------------------------------------------
        function test_JS1_to_JS6 (obj)
            % Test JS1 to JS6 only is the same as full parameter array with JS7
            % onwards set to zero. Tests variable length parameter array input.
            par = obj.par0;
            par(3:8) = obj.JS(1:6);
            
            [wfull, wtfull] = disp_fcc_hfm(obj.qh_ref, obj.qk_ref, obj.ql_ref, par);
            [w, wt] = disp_fcc_hfm(obj.qh_ref, obj.qk_ref, obj.ql_ref, par(1:8));
            assertEqualToTol(wfull, w, obj.tol);
            assertEqualToTol(wtfull, wt, obj.tol);
        end
        
        %--------------------------------------------------------------------------
        function test_absolute_energy_JS_one_at_a_time (obj)
            % Test absolute energy value - a test that no foolish factors of 2
            % or whatever have crept into a change to the code!
            for i=1:15
                par = obj.par0;
                par(i+2) = obj.JS(i);
                [w, wt] = disp_fcc_hfm(obj.qh_ref, obj.qk_ref, obj.ql_ref, par);
                assertEqualToTol(w{1}, obj.w_JS(i), obj.tol);
                assertEqualToTol(wt{1}, obj.Seff/2, obj.tol);
            end
        end
        
        %--------------------------------------------------------------------------
        function test_absolute_energy_value_gap_JS1_to_JS15 (obj)
            % Test absolute energy value - a test that no foolish factors of 2
            % or whatever have crept into a change!
            par = [obj.Seff, obj.gap, obj.JS];
            
            [w, wt] = disp_fcc_hfm(obj.qh_ref, obj.qk_ref, obj.ql_ref, par);
            assertEqualToTol(w{1}, obj.w_tot, obj.tol);
            assertEqualToTol(wt{1}, obj.Seff/2, obj.tol);
        end
        
        %--------------------------------------------------------------------------
    end
end


%==================================================================================
function Q = QsymRelated (qh, qk, ql, rlp)
% Get all symmetry related Q points of an input point for a cubic lattice.
% The excitation energies from a dispersion relation at each of the output points
% should all be identical.
%
%   >> Q = QsymRelated (h, k, l)
%   >> Q = QsymRelated (h, k, l, rlp)
%
% Input:
% ------
%   h, k, l     Point in reciprocal lattice (in rlu) (each is scalar)
% Optional:
%   rlp         Set of reciprocal lattice points; size(rlp) is [nrlp,3]
%               Each element should be an integer and each row corresponds to a
%               zone centre in the reciprocal lattice
%               For example, for bcc cubic h+k+l is even, fcc h,k,l are all odd
%               or all even, and for simple cubic h,k,l are all even.
%               [No check of rlp is performed by this algorithm.]
%               If rlp is not given, the default is [0,0,0] i.e. no offset to Q
%
% Output:
% -------
%   Q           Array size [n,3] of symmetry related Q points offset by all the
%               zone centres in input argument rlp, if given.
%
% Q_h00 = [h,0,0];      6-fold
% Q_hh0 = [h,h,0];      12-fold
% Q_hhh = [h,h,h];      8-fold
% Q_hk0 = [h,k,0];      24-fold
% Q_hhk = [h,h,k];      24-fold
% Q_hkl = [h,k,l];      48-fold

% Permute the cubic axes and all inversions of axes
Q = perms([qh,qk,ql]);
Q = [Q; perms([qh,qk,-ql])];
Q = [Q; perms([qh,-qk,ql])];
Q = [Q; perms([qh,-qk,-ql])];
Q = [Q; perms([-qh,qk,ql])];
Q = [Q; perms([-qh,qk,-ql])];
Q = [Q; perms([-qh,-qk,ql])];
Q = [Q; perms([-qh,-qk,-ql])];

% Retain unique values only (e.g. if [qh,qk,ql] = [0.1,0.1,0] there will be only
% 12 symmetry related sites.
Q = unique(Q,'rows');
nQ = size(Q,1);     % number of Q points

% Accumulate for each rlp in turn
if exist('rlp','var')
    nrlu = size(rlp,1); % number of rlp
    if nrlu==1
        Q = Q + rlp;    % to get get correct array dimensions cannot use repelem
    else
        Q = repmat(Q,[nrlu,1]) + ...
            [repelem(rlp(:,1),nQ), repelem(rlp(:,2),nQ), repelem(rlp(:,3),nQ)];
    end
end

end
