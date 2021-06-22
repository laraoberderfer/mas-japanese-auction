{ include("common.asl") }

// Agent in project versionA

/* Initial beliefs and rules */
nSucesses(0).
nFailures(0).
money(0).
counter(0).
maxBid(0).

/* Initial goals */

!getMoney.
!chooseProdsQuantity.


/* Plans  */

+new_gr(Workspace, GroupName)
  <- .print("Joining workspace ", Workspace, "...");
    joinWorkspace(Workspace, WspId);

    lookupArtifact("screen",ScreenId);
    focus(ScreenId);
    .print("Focused screen");

    .print("Searching group...");
    lookupArtifact(GroupName, GrArtId);
    .print("Adopting comprador role...");
    adoptRole(comprador)[artifact_id(GrArtId)];
    .print("Focusing in group...");
    focus(GrArtId)[wid(WspId)];
    .

+!join_room
  : screenStatus(G) &
    wantToBuy(G, I) &
    money(M) & 
    I < M 
  <- !getMaxBid(G, I);
    .concat("/main/auction_room_", G, RoomName);
    joinWorkspace(RoomName, AuctionRoomId);
    .print("I want to buy this prod and I have money for the minimum price");
    .print("Joined auction's room");
    lookupArtifact(G, GId);
    focus(GId);
    addBidder [artifact_id(GId)];
    .print("Focused ", G);
    .
  
+!join_room
  :  screenStatus(G) &
      wantToBuy(G, _)
  <- .print("I want to buy this prod but I don't have money for the minimum price");
    -wantToBuy(G, _);
    +didNotBuy(G);
    -+nFailures(F+1);
    .

+!join_room <- .print("I don't want to buy this prod.").
    
+!getMoney
  : .random(R)
  <- -+money(math.round(R*10000)+1000);
     .print("I have ", math.round(R*10000)+1000, "$").

+!chooseProdsQuantity
  : .random(R) &
    nProds(NG) &
    N = math.ceil(NG*R)
  <- +prodsQuantity(N);
     !chooseProds.

+!chooseProds
  : prodsQuantity(N) &
    counter(C) &
    C < N 
  <- .findall(X, prods(X, _), ProdsList);
     .shuffle(ProdsList, ProdsListShuffled);
     .nth(0, ProdsListShuffled, G);
     ?prods(G, I);
     +wantToBuy(G, I);
     -prods(G, _);
     -+counter(C+1);
     !chooseProds.

+!chooseProds 
  <- //+wantToBuy("prod1", 100);
     //+wantToBuy("prod2", 200); 
    .findall(X, wantToBuy(X, _), L);
     .print("I want to buy ", L);
     .abolish(prods(_,_));
     +prodsList(L);
     -counter(_).

     
+raisedPrice [artifact_id(GId)]
  : maxBid(M) &
    price(P) [artifact_id(GId)] &
    M < P &
    nFailures(F)
  <- .print("Max bid is less than new price. I am leaving the room");
     removeBidder [artifact_id(GId)];
     ?name(G);
     -wantToBuy(G, _);
     +didNotBuy(G)
     stopFocus(GId);
     -+nFailures(F+1);
     .concat("/main/auction_room_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     quitWorkspace(A).

+raisedPrice [artifact_id(GId)]
  : money(M) &
    price(P) [artifact_id(GId)] &
    M < P &
    nFailures(F)
  <- .print("Money is less than new price. I am leaving the room");
     removeBidder [artifact_id(GId)];
     ?name(G);
     -wantToBuy(G, _);
     +didNotBuy(G)
     stopFocus(GId);
     -+nFailures(F+1);
     .concat("/main/auction_room_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     quitWorkspace(A).

+raisedPrice [artifact_id(GId)].

+sold [artifact_id(GId)]
  : money(M) &
    price(P) &
    nSucesses(S)
  <- ?name(G);
    -+money(M - P);
     .print("I bought ", G, " for ", P, "$.");
     .print("Now I have ", M-P, "$.");
     .my_name(N);
      sold2(N) [artifact_id(GId)];
      +bought(G, P);
     -+nSucesses(S+1);
     -wantToBuy(G, _);
      stopFocus(GId);
     .print("Leaving the room");
     .concat("/main/auction_room_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     quitWorkspace(A).