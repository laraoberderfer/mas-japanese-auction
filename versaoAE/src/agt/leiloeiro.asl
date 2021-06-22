{ include("produtos.asl") }

// Agent sample_agent in project versionA

/* Initial beliefs and rules */


/* Initial goals */

!start.

/* Plans */

+!start
    <- joinWorkspace(arena, AuctionWSPId);
       .print("Entrou na arena");
       makeArtifact("screen", "auction_tools.AuctionScreen", [], ScreenId) [wid(AuctionWSPId)];
       !startAuctions.

+!startAuctions
    :  .findall(X, produtos(X, _), ProdsList) &
       ProdsList \== []
    <- .wait(100);
       .nth(0, ProdsList, G)
       ?produtos(G, P)
       
       .concat("prod_", G, RoomName);
        createWorkspace(RoomName);
        joinWorkspace(RoomName, AuctionRoomId);
        .print("Entrou na sala: ",RoomName);
        
        setStatus(G) [wid(AuctionWSPId), artifact_id(ScreenId)];
        makeArtifact(G, "auction_tools.AuctionArtifact", [], GId)[wid(AuctionRoomId)];
        focus(GId) [wid(AuctionRoomId)];
        setProd(G, P) [artifact_id(GId)];
       
       //.print("Auction for ", G, " started!");
       //.print(G, "'s value is now ", P, "!");
       
       .print("Leilão para ", G, " iniciou!");
       .print(G, ": valor agora eh de R$ ", P, " reais!");
       .wait(100);
       !checkParticipants(G, GId).

+!startAuctions
    <- 
       .print("------- Todos os produtos foram leiloados -------");
       //.print("All auctions have finished");
       setStatus("finished") [wid(AuctionWSPId), artifact_id(ScreenId)].

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
       -produtos(G, _);
       .concat("prod_", G, RoomName);
       ?joinedWsp(A,_,RoomName);
       quitWorkspace(A);
       !startAuctions.


+!checkParticipants(G, GId)
    <- !annouceNoBidder(G, GId).


+!raisePrice(G, GId)
    <- raisePrice [artifact_id(GId)];
       ?price(P);
      //.print(G, "'s value is now ", P, "!");
      .print(G, ": valor agora eh de R$ ", P, " reais!");
      !checkParticipants(G, GId).


+!annouceNoBidder(G, GId)
    : produtos(G, P)
    <- 
       .print("Sem lances para o produto ", G, " por R$ ", P, " reais!");
       //.print("No bidder for ", G, " for ", P, "$!");
       notSold [artifact_id(GId)];
       stopFocus(GId);
       -produtos(G, P);
       .concat("prod_", G, RoomName);
       ?joinedWsp(A,_,RoomName);
       quitWorkspace(A);
       !startAuctions.
