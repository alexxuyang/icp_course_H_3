#!/usr/bin/ic-repl
// assume we already installed the greet canister

// change to id1
identity default "./id1.pem";

// import the default canister, need: dfx start --clean
import canister = "rrkah-fqaaa-aaaaa-aaaaq-cai";

// setup three Principals, multi-sig model is 2 / 3 
call canister.init(vec {principal "cnh44-cjhoh-yyoqz-tcp2t-yto7n-6vlpk-xw52p-zuo43-rrlge-4ozr5-6ae"; principal "ndb4h-h6tuq-2iudh-j3opo-trbbe-vljdk-7bxgi-t5eyp-744ga-6eqv6-2ae"; principal "lzf3n-nlh22-cyptu-56v52-klerd-chdxu-t62na-viscs-oqr2d-kyl44-rqe"}, 2);

//---------------CREATE CANISTER---------------//

// change to id1
identity default "./id1.pem";

// propose to create a canister by id1
call canister.propose(variant {createCanister}, null, null);
let proposal_id1 = _.id;

// approve the proposal by id1
call canister.approve(proposal_id1);

// change to id2
identity default "./id2.pem";

// approve the proposal by id2
call canister.approve(proposal_id1);

let canister_id = _.canister_id?;

//---------------Permission Check---------------//

call canister.get_permission(canister_id);

assert _? == true;

//---------------Change Permission to FALSE ---------------//

// change to id1
identity default "./id1.pem";

// propose to create a canister by id1
call canister.propose(variant {removePermission}, opt canister_id, null);
let proposal_id2 = _.id;

// approve the proposal by id1
call canister.approve(proposal_id2);

// change to id2
identity default "./id2.pem";

// approve the proposal by id2
call canister.approve(proposal_id2);

call canister.get_permission(canister_id);

assert _? == false;

//---------------Refuse a Proposal ---------------//

// change to id1
identity default "./id1.pem";

// propose to create a canister by id1
call canister.propose(variant {addPermission}, opt canister_id, null);
let proposal_id3 = _.id;

// approve the proposal by id1
call canister.approve(proposal_id3);

// change to id2
identity default "./id2.pem";

// refuse the proposal by id2
call canister.refuse(proposal_id3);

// change to id3
identity default "./id3.pem";

// refuse the proposal by id3
call canister.refuse(proposal_id3);

let proposal3 = _;

call canister.get_permission(canister_id);

assert _? == false;

assert proposal3 ~= record {finished = true; refusers = vec {principal "cnh44-cjhoh-yyoqz-tcp2t-yto7n-6vlpk-xw52p-zuo43-rrlge-4ozr5-6ae"; principal "lzf3n-nlh22-cyptu-56v52-klerd-chdxu-t62na-viscs-oqr2d-kyl44-rqe"} };
