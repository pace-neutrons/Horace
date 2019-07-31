classdef test_rand_like< TestCase
    properties
        this_folder
        test_ref_f = 'rand_like_ref_sequence.mat'
        ref_seq
    end
    methods
        function this=test_rand_like(name)
            this = this@TestCase(name);
            this.this_folder = fileparts(which('test_rand_like.m'));
            ref_file = fullfile(this.this_folder,this.test_ref_f);
            if exist(ref_file,'file')==2
                ref_seq= load(ref_file);
                this.ref_seq = ref_seq.ref_seq;
            else
                rand_like('start',42);
                ref_seq = rand_like([64*1024,1]);
                this.ref_seq = ref_seq;
                save(ref_file,'ref_seq');
            end
            
        end
        
        function test_rand_like_consistency(this)
            rand_like('start',42);
            test_seq = rand_like([64*1024,1]);
            assertEqual(test_seq,this.ref_seq);
        end
        function test_consistency2(this)
            seeds_data= load(fullfile(this.this_folder,'sim_spe_testfun_seeds_file.mat'));
            seed1 = seeds_data.rnd_storage.seeds.gen_sqw_acc_sqw_spe_nomex1;
            seed2 = seeds_data.rnd_storage.seeds.gen_sqw_acc_sqw_spe_nomex1_fun;
            rand_like('start',seed1);
            seq1=rand_like([13921,1]);
            rand_like('start',seed2);
            seq2=rand_like([13921,1]);
            sample_file = fullfile(this.this_folder,'rand_like_ref_sequence2.mat');
            if exist(sample_file,'file')==2
                ref = load(sample_file);
                assertEqual(ref.seq1,seq1);
                assertEqual(ref.seq2,seq2);
            else
                save(sample_file,'seq1','seq2');
            end
        end
        
    end
end
