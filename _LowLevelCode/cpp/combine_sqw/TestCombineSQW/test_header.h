#ifndef H_TEST_MAIN_DATAHANDLING_
#define H_TEST_MAIN_DATAHANDLING_

#include <cxxtest/TestSuite.h>

class test_sqw: public CxxTest::TestSuite
{
public:
      void testTMain(void)
      {
        TS_WARN( "Test suite invoked" );
      }
};
#endif