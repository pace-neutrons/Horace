#include "cpp_communicator/MPI_wrapper.h"
#include "cpp_communicator/input_parser.h"
#include "cpp_communicator/cpp_communicator.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Herbert::Utility;


TEST(TestCPPCommunicator, send_assynchroneous) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true,4,6);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 6);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(10,1,false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    test_mess.assign(10, 2);
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    test_mess.assign(10, 3);
    test_mess[0] = 0; // mark message delivered
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(2, wrap.assync_queue_len());

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(3, wrap.assync_queue_len());

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(4, wrap.assync_queue_len());
    // queue full
    ASSERT_ANY_THROW(wrap.labSend(10, 1, false, &test_mess[0], test_mess.size()));

    // Mark all messages as delivered
    auto MessCache = wrap.get_async_queue();

    auto last = MessCache->rbegin();
    last->theRequest = true; // mark last message delivered;
    wrap.labSend(9, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.assync_queue_len());


    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        it->theRequest = true;
    }
    wrap.labSend(8, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

}

TEST(TestCPPCommunicator, lab_probe_single) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    std::vector<int32_t> req_address(1,-1);
    std::vector<int32_t> req_tag(1,-1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(),0);


    std::vector<uint8_t> test_mess(10,1);
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    req_address[0] = 9;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 10;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    req_address[0] = 10;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 10;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    //
    wrap.labSend(9, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(wrap.assync_queue_len(),2);

    // Mark last messages as delivered
    auto MessCache = wrap.get_async_queue();
    auto lastMess = MessCache->rbegin();
    lastMess->theRequest = 1;

    req_address[0] = -1;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 2);

    req_address[0] = 10;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 9;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 2);
}

TEST(TestCPPCommunicator, lab_probe_multi) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    std::vector<int32_t> req_address(2, -1);
    std::vector<int32_t> req_tag(1, -1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);


    std::vector<uint8_t> test_mess(10, 1);
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(8, 2, false, &test_mess[0], test_mess.size());
    wrap.labSend(5, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.assync_queue_len());

    req_address[0] = 8;
    req_address[1] = 3;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);

    req_tag[0] = 3;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);

    req_address.push_back(5);
    req_tag.push_back(5);
    req_tag.push_back(3);

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 2);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);
    ASSERT_EQ(got_address[1], 5);
    ASSERT_EQ(got_tag[1], 3);


}

TEST(TestCPPCommunicator, lab_receive_as_send) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    mxArray* plhs[5];
    wrap.labReceive(10, 1, false, plhs,5);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out),1);
    ASSERT_EQ(mxGetN(out), 0);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);


    ASSERT_ANY_THROW(wrap.labReceive(10, 1, true, plhs,5));

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    for (int i = 0; i < test_mess.size(); i++) {
        test_mess[i] = i;
    }
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(10, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labReceive(-1, -1, false, plhs,5);

    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<char*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(test_mess[i], pData[i]);
    }
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t *>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 10);
    ASSERT_EQ(pAddress[1], 2);

    wrap.labReceive(10, 2, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 0);

    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);

    wrap.labSend(5, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labReceive(5, 2, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 0);
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);


    wrap.labReceive(5, 3, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    pData = reinterpret_cast<char*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(test_mess[i], pData[i]);
    }
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], 3);


    //delete(plhs[(int)labReceive_Out::mess_contents]);
    //delete(plhs[(int)labReceive_Out::data_celarray]);

}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
