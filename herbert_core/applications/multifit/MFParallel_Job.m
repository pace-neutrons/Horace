classdef MFParallel_Job < JobExecutor

    properties
        yval;
        wt;
        npts;

        nnorm;
        npfree;
        nval;

        f_best;
        p_best;
        c_best;
        chisqr_red;

        iter = 1;
        dp;
        niter;
        tol;
        lambda = 1;

        converged = false;
        finished = false;

        S;
        Store;

    end

    properties(Constant)
        lambda_table=[1e1 1e1 1e2 1e2 1e2 1e2];
    end

    methods
        % Constructor cannot take args as constructed by JobDispatcher
        function obj = MFParallel_Job()
            obj = obj@JobExecutor();
        end

        function obj=reduce_data(obj)
            % Performed at end of do job after synchronise

            obj.iter = obj.iter + 1;
            obj.finished = obj.finished || (obj.iter >= obj.niter);
        end

        function ok = is_completed(obj)
            % If returns true, job will not run another cycle of do_job/reduce_data
            ok = obj.finished;
        end

        function obj = setup(obj)
            data = obj.loop_data_{1};

            if isfield(data, 'tobyfit_data')
                for i=1:numel(data.tobyfit_data)
                    obj.common_data_.pin(i).plist_{3} = data.tobyfit_data{i};
                end
            end

            common = obj.common_data_;

            obj.finished = ~common.perform_fit;

            obj.p_best = common.p;
            obj.converged = false;

            % Set fit control parameters
            obj.dp = common.fcp(1);      % derivative step length
            obj.niter = common.fcp(2);   % maximum number of iterations
            obj.tol = common.fcp(3);     % convergence criterion

            % Package data values and weights (i.e. 1/error_bar) each into a single column vector

            w = data.w;

            % Package data values and weights (i.e. 1/error_bar) each into a single column vector
            obj.yval=cell(size(w));
            obj.wt=cell(size(w));
            for i=1:numel(w)
                if data.xye(i)   % xye triple - we have already masked all unwanted points
                    obj.yval{i}=w{i}.y;
                    obj.wt{i}=1./w{i}.e;
                else        % a different data object: get data to be fitted
                    [obj.yval{i},obj.wt{i},msk]=sigvar_get(w{i});
                    obj.yval{i}=obj.yval{i}(msk);         % remove the points that we are told to ignore
                    obj.wt{i}=1./sqrt(obj.wt{i}(msk));
                end
                obj.yval{i}=obj.yval{i}(:);         % make a column vector
                obj.wt{i}=obj.wt{i}(:);         % make a column vector
            end
            obj.yval = obj.merge_section(obj.yval);
            obj.wt = obj.merge_section(obj.wt);

            % Check that there are more data points than free parameters
            obj.nval = numel(obj.yval);

            obj.npts = obj.reduce(1, obj.nval, @vertcat, 'args');
            nvals = sum(obj.npts);
            obj.npfree = numel(common.p);

            if obj.is_root
                if nvals < obj.npfree
                    error("HERBERT:mfclass:multifit_lsqr",'Number of data points must be greater than or equal to the number of free parameters')
                end

                obj.nnorm = max(nvals-obj.npfree,1);   % we allow for the case nval=npfree

            end

            [f, ~, obj.S, obj.Store] = multifit_lsqr_func_eval( ...
                data.w, ...
                data.xye, ...
                common.func, ...
                common.bfunc, ...
                common.pin, ...
                common.bpin, ...
                common.f_pass_caller_info, ...
                common.bf_pass_caller_info, ...
                common.p, ...
                common.p_info, ...
                true, ...
                obj.S, ...
                obj.Store , ...
                0);


            f = obj.merge_section(f);
            resid=obj.wt.*(obj.yval-f);

            chi=resid'*resid; % Un-normalised chi-squared
            obj.c_best = obj.reduce(1, chi, @sum);
            obj.f_best = f;

            if obj.is_root && ~common.perform_fit
                obj.chisqr_red = obj.c_best/obj.nnorm;
            end

        end

        function obj = do_job(obj)

            timer = tic;
            data = obj.loop_data_{1};
            common = obj.common_data_;

            max_rescale_lambda=false;

            obj.p_best = obj.bcast(1, obj.p_best);

            jac=obj.multifit_dfdpf(...
                data.w, ...
                data.xye, ...
                common.func, ...
                common.bfunc, ...
                common.pin, ...
                common.bpin, ...
                common.f_pass_caller_info, ...
                common.bf_pass_caller_info, ...
                obj.p_best, ...
                common.p_info, ...
                obj.f_best, ...
                obj.dp, ...
                obj.S, ...
                obj.Store);

            % Compute Jacobian matrix
            sumArr = @(varargin) sum(cat(3, varargin{:}), 3);

            jac=obj.wt.*jac;
            nrm = dot(jac, jac);
            nrm = obj.reduce(1, nrm, sumArr, 'args');
            nrm = obj.bcast(1, nrm);
            nrm(nrm > 0) = 1 ./ sqrt(nrm(nrm > 0));

            jac = nrm .* jac;
            resid = obj.wt.*(obj.yval-obj.f_best);


            N = jac'*jac;
            N = obj.reduce(1, N, sumArr, 'args');

            if obj.is_root
                [v, s] = eig(N, 'vector');
                s = sqrt(s);
            else
                v = zeros(obj.npfree, obj.npfree);
                s = zeros(obj.npfree, 1);
            end

            [s, v] = obj.bcast(1, s, v);

            jac = jac * (v ./ s');

            g = jac' * resid;
            clear jac;
            clear resid;

            if obj.is_root
                % Compute change in parameter values.
                % If the change does not improve chisqr  then increase the
                % Levenberg-Marquardt parameter until it does (up to a maximum
                % number of times given by the length of lambda_table).
                if obj.tol>0
                    c_goal=(1-obj.tol)*obj.c_best;  % Goal for improvement in chisqr
                else
                    c_goal=obj.c_best-abs(obj.tol);
                end

            end

            obj.lambda=obj.lambda/10;

            for itable=1:numel(obj.lambda_table)

                se = sqrt((s.*s) + obj.lambda);
                gse = g ./ se;
                p_chg = (v*gse).*nrm';
                p_chg = obj.reduce(1, p_chg, sumArr, 'args');
                p_chg = obj.bcast(1, p_chg);

                if (any(abs(p_chg)>0))  % there is a change in (at least one of) the parameters
                    p=obj.p_best+p_chg;

                    [f, ~, obj.S, obj.Store] = multifit_lsqr_func_eval( ...
                        data.w, ...
                        data.xye, ...
                        common.func, ...
                        common.bfunc, ...
                        common.pin, ...
                        common.bpin, ...
                        common.f_pass_caller_info, ...
                        common.bf_pass_caller_info, ...
                        p, ...
                        common.p_info, ...
                        true, ...
                        obj.S, ...
                        obj.Store , ...
                        0);

                    f = obj.merge_section(f);
                    resid=obj.wt.*(obj.yval-f);
                    chi=resid'*resid;

                    c = obj.reduce(1, chi, @sum);

                    improved = obj.is_root && (c < obj.c_best || c==0);
                    improved = obj.bcast(1, improved);

                    if improved
                        obj.p_best=p;
                        obj.f_best=f;
                        obj.c_best=c;
                        break;
                    end

                end

                if itable==numel(obj.lambda_table) % Gone to end of table without improving chisqr
                    max_rescale_lambda=true;
                    break;
                end

                % Chisqr didn't improve - increase lambda and recompute step in parameters
                obj.lambda = obj.lambda*obj.lambda_table(itable);
            end

            if obj.is_root
                % If chisqr lowered, but not to goal, so converged; or chisqr==0 i.e. perfect fit; then exit loop
                obj.converged = (obj.c_best>c_goal) || (obj.c_best==0);

                % If multipled lambda to limit of the table, give up
                obj.finished = obj.converged || max_rescale_lambda;
            end

            [obj.converged, obj.finished] = obj.bcast(1, obj.converged, obj.finished);

            tend = toc(timer);
            obj.log_progress(obj.iter, obj.niter, tend, '')

        end

        function obj = finalise(obj)
        % Wrap up for exit from fitting routine

            data = obj.loop_data_{1};
            common = obj.common_data_;
            obj.p_best = obj.bcast(1, obj.p_best);

            if obj.converged
                % Calculate covariance matrix
                % Recompute and store functions values at best parameters. (The stored values may not be
                % those for best parameters which will otherwise dramatically slow down the calculation
                % of the covariance matrix. If the stored values are for the best parameters, then this
                % is a low cost function call, so there is little penalty.)

                [~, ~, obj.S, obj.Store] = multifit_lsqr_func_eval( ...
                    data.w, ...
                    data.xye, ...
                    common.func, ...
                    common.bfunc, ...
                    common.pin, ...
                    common.bpin, ...
                    common.f_pass_caller_info, ...
                    common.bf_pass_caller_info, ...
                    obj.p_best, ...
                    common.p_info, ...
                    true, ...
                    obj.S, ...
                    obj.Store , ...
                    0);

                % Now get Jacobian matrix
                jac=obj.multifit_dfdpf(...
                    data.w, ...
                    data.xye, ...
                    common.func, ...
                    common.bfunc, ...
                    common.pin, ...
                    common.bpin, ...
                    common.f_pass_caller_info, ...
                    common.bf_pass_caller_info, ...
                    obj.p_best, ...
                    common.p_info, ...
                    obj.f_best, ...
                    obj.dp, ...
                    obj.S, ...
                    obj.Store);

                jac=obj.wt.*jac;
                jac = obj.reduce(1, jac, @vertcat, 'args');

                if obj.is_root
                    obj.chisqr_red = obj.c_best/obj.nnorm;

                    [~,s,v]=svd(jac,0);
                    s=repmat((1./diag(s))',[obj.npfree,1]);
                    v=v.*s;
                    cov=obj.chisqr_red*(v*v');  % true covariance matrix;
                    sig=sqrt(diag(cov));
                    tmp=repmat(1./sqrt(diag(cov)),[1,obj.npfree]);
                    cor=tmp.*cov.*tmp';

                end

            else
                if obj.is_root
                    obj.chisqr_red = obj.c_best/obj.nnorm;
                end
                sig=zeros(1,numel(obj.p_best));
                cor=zeros(numel(obj.p_best));
            end

            if obj.is_root
                obj.task_outputs = struct('p_best', obj.p_best, 'sig', sig, 'cor', cor, 'chisqr_red', obj.chisqr_red, 'converged', obj.converged);

            else
                obj.task_outputs = [];
            end

        end

    end

    methods
        function jac=multifit_dfdpf(obj,w,xye,func,bfunc,pin,bpin,...
                f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,Store)
            % Calculate partial derivatives of function with respect to parameters
            %
            %   >> jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,...
            %           f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,Store)
            %
            % Input:
            % ------
            %   w       Cell array of data objects
            %   xye     Logical array sye(i)==true if w{i} is x-y-e triple
            %   func    Handle to global function
            %   bfunc   Cell array of handles to background functions
            %   pin     Function arguments for global function
            %   bpin    Cell array of function arguments for background functions
            %   f_pass_caller_info  Keep internal state of foreground function evaluation
            %   bf_pass_caller_info Keep internal state of background function evaluation
            %   p       Parameter values of free parameters
            %   p_info  Structure with information to convert free parameters to numerical
            %           parameters needed for function evaluation
            %   f       Function values at parameter values p sbove
            %   dp      Fractional step change in p for calculation of partial derivatives
            %                - if dp > 0    calculate as (f(p+h)-f(p))/h
            %                - if dp < 0    calculate as (f(p+h)-f(p-h))/(2h)
            %   S       Structure containing stored values and internal states of functions
            %   Store   Stored values of e.g. expensively evaluated lookup tables that
            %           have been accumulated to during evaluation of the fit functions
            %
            % Output:
            % -------
            %   jac     Matrix of partial derivatives: m x n array where m=length(f) and
            %           n = length(p)
            %
            %
            % Note that the call to multifit_lsqr_func_eval in this function is only ever
            % with store_calc==false. Consequently the stored value structure is never
            % updated, so we do not need to pass it back from this function.
            % Similarly, any accumulating lookup tables are not stored, as these will be
            % for changes to parameters in the calculation of partial derivatives, and
            % so are not returned.

            jac=zeros(obj.nval,length(p)); % initialise Jacobian to zero
            min_abs_del=1e-12;

            for j=1:length(p)

                del=dp*p(j);                % dp is fractional change in parameter

                if abs(del)<=min_abs_del    % Ensure del non-zero
                    if p(j)>=0
                        del=min_abs_del;
                    else
                        del=-min_abs_del;
                    end
                end

                if dp>=0
                    ppos=p;
                    ppos(j)=p(j)+del;

                    plus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
                        f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,Store,0);


                    plus = obj.merge_section(plus);
                    jac(:, j) = (plus-f)/del;

                else
                    ppos=p;
                    ppos(j)=p(j)+del;
                    pneg=p;
                    pneg(j)=p(j)-del;
                    plus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
                        f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,Store,0);
                    minus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
                        f_pass_caller_info,bf_pass_caller_info,pneg,p_info,false,S,Store,0);

                    plus = obj.merge_section(plus);
                    minus = obj.merge_section(minus);
                    jac(:, j) = (plus - minus)/(2*del);
                end
            end

        end
    end

    methods(Hidden)

        function data = merge_section(obj, data)
            merge_data = obj.common_data_.merge_data;

            merge = ~arrayfun(@(x) x(1).nomerge, merge_data)';

            nw = numel(data);

            for iw = 1:nw
                if merge(1, iw)
                    for currID = obj.numLabs:-1:2
                        if merge(currID, iw)
                            if currID == obj.labIndex  % I am merging down
                                send_data = DataMessage(data{iw}(1));
                                [ok, err_mess] = obj.mess_framework.send_message(currID-1, send_data);
                                if ~ok
                                    error('HORACE:MFParallel_Job:send_error', err_mess)
                                end
                                data{iw} = data{iw}(2:end); % Drop merged element

                            elseif currID == obj.labIndex+1 % I am being merged onto
                                [ok, err_mess, in_data] = obj.mess_framework.receive_message(currID, 'data');
                                if ~ok
                                    error('HORACE:MFParallel_Job:receive_error', err_mess)
                                end
                                adat = merge_data(obj.labIndex, iw).nelem(2);
                                bdat = merge_data(currID, iw).nelem(1);
                                data{iw}(end) = data{iw}(end)*adat + ...
                                    in_data.payload*bdat / (adat + bdat);
                            end
                        end
                    end

                end
            end

            data = cat(1,data{:});

        end

    end

end
