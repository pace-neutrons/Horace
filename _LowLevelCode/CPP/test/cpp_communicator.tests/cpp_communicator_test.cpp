#include "cpp_communicator/MPI_wrapper.h"
#include "cpp_communicator/input_parser.h"
#include "cpp_communicator/cpp_communicator.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Herbert::Utility;


TEST(TestCPPCommunicator, send_assynchroneous) {

    auto wrap = MPI_wrapper();
    wrap.init(true,4);
    ASSERT_TRUE(wrap.isTested);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.send(10,1,false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    test_mess.assign(10, 2);
    wrap.send(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    test_mess.assign(10, 3);
    test_mess[0] = 0; // mark message delivered
    wrap.send(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.send(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(2, wrap.assync_queue_len());

    wrap.send(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(3, wrap.assync_queue_len());

    wrap.send(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(4, wrap.assync_queue_len());
    // queue full
    ASSERT_ANY_THROW(wrap.send(10, 1, false, &test_mess[0], test_mess.size()));

    // Mark all messages as delivered
    auto MessCache = wrap.get_async_queue();

    auto last = MessCache->rbegin();
    last->theRequest = true; // mark last message delivered;
    wrap.send(9, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.assync_queue_len());


    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        it->theRequest = true;
    }
    wrap.send(8, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());


}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
