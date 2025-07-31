#include "sort_pixels_by_bins/sort_pixels_by_bins.h"
#include <gtest/gtest.h>




TEST(TestSortPixels, test_process_types) {
    /* Test switches within process types function*/

    EXPECT_EQ(process_types(true, IndD64, false), Pix4IndDOut4);
    EXPECT_EQ(process_types(true, IndD64, true), Pix4IndDOut8);

    EXPECT_EQ(process_types(true, IndI64, false), Pix4IndIOut4);
    EXPECT_EQ(process_types(true, IndI64, true), Pix4IndIOut8);

    EXPECT_EQ(process_types(true, IndF32, false), Pix4Ind4Out4);
    EXPECT_EQ(process_types(true, IndF32, true), Pix4Ind4Out8);


    EXPECT_EQ(process_types(false, IndD64, false), Pix8IndDOut8);
    EXPECT_EQ(process_types(false, IndD64, true), Pix8IndDOut8);

    EXPECT_EQ(process_types(false, IndI64, false), Pix8IndIOut8);
    EXPECT_EQ(process_types(false, IndI64, true), Pix8IndIOut8);

    EXPECT_EQ(process_types(false, IndF32, false), Pix8Ind4Out8);
    EXPECT_EQ(process_types(false, IndF32, true), Pix8Ind4Out8);

}

