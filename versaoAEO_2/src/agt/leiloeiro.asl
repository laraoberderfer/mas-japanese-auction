{ include("common.asl") }

// Agent sample_agent in project versionA

/* Initial beliefs and rules */


/* Initial goals */

!create_org.

/* Plans */

+!create_org
    <- .print("Creating workspace auction_wsp...");
       createWorkspace(auction_wsp);

       .print("Joining workspace auction_wsp...");
       joinWorkspace(auction_wsp, AuctionWspId);

       makeArtifact("screen", "auction_tools.AuctionScreen", [], ScreenId) [wid(AuctionWSPId)];
       focus(ScreenId) [wid(AuctionWspId)];

       .print("Creating auction_org...");
       makeArtifact(org1, "ora4mas.nopl.OrgBoard", ["src/org/auction-os.xml"], OrgArtId)[wid(AuctionWspId)];
       
       .print("Focusing in org artifact...");
       focus(OrgArtId) [wid(AuctionWspId)];

       .print("Creating group...");
       createGroup(group1, auction_group, GrArtId)[artifact_id(OrgArtId)];
       
       .print("Focusing in group...");
       focus(GrArtId)[wid(AuctionWspId)];
       
       .print("Adopting leiloeiro role...");
       adoptRole(leiloeiro)[artifact_id(GrArtId)];

       .print("Broadcasting group...");
       .broadcast(tell, new_gr(auction_wsp, group1));

       .print("Waiting group to be formed...");
       .wait(formationStatus(ok)[artifact_id(GrArtId)]);

       !create_scheme;
       .

+!create_scheme
    : .findall(X, prods(X, _), ProdsList) &
       ProdsList \== []
    <- .wait(100);
       .nth(0, ProdsList, G);
       ?prods(G, P);
        +currentAuction(G, P);
       .concat("scheme_for_", G, SchemeName); 
       .print("Creating scheme...");
       createScheme(SchemeName, auction_scheme, SchArtId)[artifact_id(OrgArtId)];
       
       .print("Adding scheme...");
       addScheme(SchemeName)[artifact_id(GrArtId)];
       
       .print("Focusing in scheme...");
       focus(SchArtId)[wid(AuctionWspId)];
       .

+!create_scheme
    <- .print("");
       .print("");
       .print("------- Todos os produtos foram leiloados -------");
       .

+!create_auction_room
    : currentAuction(G, P)
    <- .print("test create auction room");

       .concat("/main/auction_room_", G, RoomName);
        createWorkspace(RoomName);
        joinWorkspace(RoomName, AuctionRoomId);
        .print("Joined auction room");

        setStatus(G) [wid(AuctionWSPId), artifact_id(ScreenId)];
        makeArtifact(G, "auction_tools.AuctionProdutos", [], GId)[wid(AuctionRoomId)];
        +currentProd(G, GId);
        focus(GId) [wid(AuctionRoomId)];
        setProd(G, P) [artifact_id(GId)];

       .print("Leilao para ", G, " iniciado!");
       .print(G, "'s value is now ", P, "!");
       .

+!do_auction
    : currentProd(G, GId)
    <- !checkParticipants(G, GId);
    .

+!finish_auction
    <- !create_scheme;
    .

+!checkParticipants(G, GId)
    : bidders(B)[artifact_id(GId)] &
      B > 1
    <- .wait(100);
       !raisePrice(G, GId).


+!checkParticipants(G, GId)
    : bidders(B)[artifact_id(GId)] &
      B == 1
    <- sold [artifact_id(GId)];
       stopFocus(GId);
       -prods(G, _);
       .concat("/main/auction_room_", G, RoomName);
       -currentProd(G, _);
       -currentAuction(G, _);
       ?joinedWsp(A,_,RoomName);
       quitWorkspace(A);
       .


+!checkParticipants(G, GId)
    <- !annouceNoBidder(G, GId).


+!raisePrice(G, GId)
    <- raisePrice [artifact_id(GId)];
       ?price(P);
      .print(G, "'s value is now ", P, "!");
      !checkParticipants(G, GId).


+!annouceNoBidder(G, GId)
    : prods(G, P)
    <- .print("No bidder for ", G, " for ", P, "$!");
       notSold [artifact_id(GId)];
       stopFocus(GId);
       -prods(G, P);
       .concat("/main/auction_room_", G, RoomName);
       -currentProd(G, _);
       -currentAuction(G, _);
       ?joinedWsp(A,_,RoomName);
       quitWorkspace(A);
       .
