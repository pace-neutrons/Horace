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
        
    end
end
