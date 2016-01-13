/* Generated file, do not edit */

#ifndef CXXTEST_RUNNING
#define CXXTEST_RUNNING
#endif

#include <cxxtest/TestListener.h>
#include <cxxtest/TestTracker.h>
#include <cxxtest/TestRunner.h>
#include <cxxtest/RealDescriptions.h>
#include <cxxtest/TestMain.h>
#include <cxxtest/ParenPrinter.h>

int main( int argc, char *argv[] ) {
 int status;
    CxxTest::ParenPrinter tmp;
    CxxTest::RealWorldDescription::_worldName = "cxxtest";
    status = CxxTest::Main< CxxTest::ParenPrinter >( tmp, argc, argv );
    return status;
}
bool suite_test_sqw_init = false;
#include "d:\users\abuts\SVN\ISIS\Horace\_LowLevelCode\cpp\combine_sqw\TestCombineSQW\test_header.h"

static test_sqw suite_test_sqw;

static CxxTest::List Tests_test_sqw = { 0, 0 };
CxxTest::StaticSuiteDescription suiteDescription_test_sqw( "d:/users/abuts/SVN/ISIS/Horace/_LowLevelCode/cpp/combine_sqw/TestCombineSQW/test_header.h", 6, "test_sqw", suite_test_sqw, Tests_test_sqw );

static class TestDescription_suite_test_sqw_testTMain : public CxxTest::RealTestDescription {
public:
 TestDescription_suite_test_sqw_testTMain() : CxxTest::RealTestDescription( Tests_test_sqw, suiteDescription_test_sqw, 9, "testTMain" ) {}
 void runTest() { suite_test_sqw.testTMain(); }
} testDescription_suite_test_sqw_testTMain;

#include <cxxtest/Root.cpp>
const char* CxxTest::RealWorldDescription::_worldName = "cxxtest";
