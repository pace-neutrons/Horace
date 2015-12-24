#pragma once
#include <cxxtest/TestSuite.h>
#include "../combine_sqw.h"



class TestCombineSQW : public CxxTest::TestSuite {
public:
    // This pair of boilerplate methods prevent the suite being created statically
    // This means the constructor isn't called when running other tests
    static TestCombineSQW *createSuite() {
        return new TestCombineSQW();
    }
    static void destroySuite(TestCombineSQW*suite) { delete suite; }

    TestCombineSQW() {}

    void test_sqw_reader_propagate_pix() {
        sqw_reader reader(128);
        fileParameters file_par;
        file_par.fileName = "d:/users/abuts/SVN/ISIS/Horace/_test/test_symmetrisation/w3d_sqw.sqw";
        file_par.file_id = 0;
        file_par.nbin_start_pos = 5194471;
        file_par.pix_start_pos = 8973651;
        file_par.total_NfileBins = 472392;
        bool initialized(false);
        try {
            reader.init(file_par, false, false, 128);
            initialized = true;
        }
        catch (...) {}

        TS_ASSERT(initialized);

        size_t pix_start_num, num_bin_pix,start_bin(0);
        std::vector<float> pix_buffer(9*1000);
        float *pPix_info = &pix_buffer[0];

        reader.get_pix_for_bin(0,pPix_info, start_bin,pix_start_num,num_bin_pix,false);
        TS_ASSERT_EQUALS(pix_start_num,0);
        TS_ASSERT_EQUALS(num_bin_pix, 3);
        // pix buffer have not changed at all
        reader.get_pix_for_bin(127, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 338);
        TS_ASSERT_EQUALS(num_bin_pix, 0);

        reader.get_pix_for_bin(126, pPix_info, start_bin, pix_start_num, num_bin_pix, false);
        TS_ASSERT_EQUALS(pix_start_num, 334);
        TS_ASSERT_EQUALS(num_bin_pix, 4);

        reader.get_npix_for_bin(256,pix_start_num,num_bin_pix);
    }

};
