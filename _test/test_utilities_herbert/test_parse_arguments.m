classdef test_parse_arguments < TestCase
    properties
    end
    methods
        function obj=test_parse_arguments(varargin)
            if nargin == 0
                name = 'test_parse_arguments';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_problem_with_parse_keywords(~)
            % General parse_keywords test (extract from removed test_parsing_2)
            [ok,mess,ind,val]=parse_keywords({'moo','hel','hello'},'hel',14);
            assertTrue(ok,['Problem with parse_keywords: ',mess]);
            assertEqual(ind,2)
            assertEqual(val{1},14)
        end

        function test_parsing_speed(varargin)
            % Test the equivalence and relative speed of parse_arguments, parse_args_simple and parse_keywords
            %
            %   >> timing_parse_functions           % Default 500 loops
            %   >> timing_parse_functions(nloop)
            %
            % Author: T.G.Perring

            if nargin==1
                nloop=500;  % default value
            else
                nloop = varargin{2};
            end

            inpars={[13,14],'hello','missus',true};
            argname={'name','newplot','type'};
            argvals={[11,12,13,14],'zoot',rand(4,3),true,false,'suit'};
            arglist = struct('name','',...
                'newplot',true,...
                'type','d');

            % Fill array of arguments to test parsing functions
            disp('Creating some test input arguments...')
            argcell=cell(1,nloop);
            argcell_key=cell(1,nloop);
            for i=1:nloop
                indpar=logical(round(rand(size(inpars))));
                indarg=logical(round(rand(size(argname))));
                indval=round(0.501+5.990*rand(1,sum(indarg)));
                args=[argname(indarg);argvals(indval)];
                argcell{i}=[inpars(indpar),args(:)'];
                argcell_key{i}=args(:)';
            end
            disp(' ')

            % Test relative speed of parse_arguments, parse_args_simple and parse_keywords
            disp('Parse_arguments')
            tic
            n=0;
            for i=1:nloop
                [par,keyword,present] = parse_arguments(argcell{i},arglist);
                n=n+numel(par)+numel(keyword)+numel(present);
            end
            n_parse_arguments=n;
            t=toc;
            disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
            disp(' ')


            disp('Parse_keywords')
            tic
            n=0;
            for i=1:nloop
                [ok,mess,ind,val] = parse_keywords(argname,argcell_key{i}{:});
                if ~ok, assertTrue(false,mess), end
                n=n+sum(ind)+numel(val);
            end
            if n==n_parse_arguments
                disp('Whoopee! (a message to prevent clever optimization by Matlab)')
            end

            t=toc;
            disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
            disp(' ')
        end

        function test_pasre_simple_key_val_list(~)

            inputs = {'input_file.dat',18,-0.5,0.6,...
                'back',[15000,19000],'mod','nonorm'};

            % Required parameters:
            par_req = {'data_source', 'ei'};

            % Optional parameters:
            par_opt = struct('emin', -0.3, 'emax', 0.95, 'de', 0.005);

            % Argument names and default values:
            keyval_def = struct('background',[12000,18000], ...
                'normalise', 1, ...
                'modulation', 0, ...
                'output', 'data.txt');

            % Arguments which are logical flags:
            flagnames = {'normalise','modulation'};
            %
            % Parse input:
            [par,out,present] = parse_arguments(inputs,...
                par_req, par_opt, keyval_def, flagnames);

            %
            % results in the output:
            r_par = struct(...
                'data_source','input_file.dat',...
                'ei',18.,...
                'emin', -0.5000,...
                'emax', 0.6000,...
                'de', 0.0050);
            r_out =struct(...
                'background',[15000 19000],...
                'normalise',false,...
                'modulation',true,...
                'output','data.txt');

            r_present =struct(...
                'data_source', true,...
                'ei', true,...
                'emin', true,...
                'emax', true,...
                'de', false,...
                'background', true,...
                'normalise', true,...
                'modulation', true,...
                'output', false);
            assertEqual(par,r_par);
            assertEqual(out,r_out);
            assertEqual(present,r_present);
        end

        function test_process_key_val_input(~)
            inputs = {'input_file.dat',18,{'hello','tiger'},...
                'back',[15000,19000],'mod','nonorm'};


            % Argument names and default values:
            keyval_def = struct('background',[12000,18000], ...
                'normalise', 1, ...
                'modulation', 0, ...
                'output', 'data.txt');

            % Arguments which are logical flags:
            flagnames = {'normalise','modulation'};

            % Parse input:
            [par, out, present] = parse_arguments(inputs, keyval_def, flagnames);

            % results in the output:
            r_par = {'input_file.dat',18,{'hello','tiger'}};

            r_out = struct(...
                'background', [15000 19000], ...
                'normalise',false, ...
                'modulation',true, ...
                'output','data.txt');

            r_present = struct(...
                'background',true,...
                'normalise',true,...
                'modulation',true,...
                'output',false);

            assertEqual(par,r_par);
            assertEqual(out,r_out);
            assertEqual(present,r_present);
        end
    end
end