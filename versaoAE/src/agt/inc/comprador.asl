{ include("produtos.asl") }

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
!join_workspace.

/* Plans */

+!getMoney
  : .random(R)
  <- -+money(math.round(R*10000)+1000);
     .print("Possui R$ ", math.round(R*10000)+1000, " reais!").

+!chooseProdsQuantity
  : .random(R) &
    nProdutos(NG) &
    N = math.ceil(NG*R)
  <- +prodsQuantity(N);
     !chooseProds.

+!chooseProds
  : prodsQuantity(N) &
    counter(C) &
    C < N 
  <- .findall(X, produtos(X, _), ProdsList);
     .shuffle(ProdsList, ProdsListShuffled);
     .nth(0, ProdsListShuffled, G);
     ?produtos(G, I);
     +wantToBuy(G, I);
     -produtos(G, _);
     -+counter(C+1);
     !chooseProds.

+!chooseProds 
  <- .findall(X, wantToBuy(X, _), L);
     .print("Tenho intensao de comprar: ", L);
     .abolish(produtos(_,_));
     +grodsList(L);
     -counter(_).

+!join_workspace
  <- joinWorkspace(arena, AuctionWSPId);
     .print("Entrou na arena");
     .wait(100)
     !focusScreen.

+!focusScreen
  <- lookupArtifact("screen",ScreenId);
     focus(ScreenId);
    .print("Focused screen").
     

+screenStatus(G)[artifact_id(ScreenId)]
  : wantToBuy(G, I) &
    money(M) & 
    I < M 
  <- !getMaxBid(G, I);
  
     .concat("prod_", G, RoomName);
     joinWorkspace(RoomName, AuctionRoomId);
     .print("Entrou na sala: ",RoomName);
     
     lookupArtifact(G, GId);
     focus(GId) [wid(AuctionRoomId)];
     addBidder [artifact_id(GId)];
     .print("Focado: ", G).

+screenStatus(G)[artifact_id(ScreenId)]
  : wantToBuy(G, _)
  <- //.print("I don't have enough money for ", G, ".");
      .print("Nao tem dinheiro suficiente para dar lance no produto: ", G, ".");
     
     -wantToBuy(G, _);
     +didNotBuy(G);
     -+nFailures(F+1).

+screenStatus(G)[artifact_id(ScreenId)].

+raisedPrice [artifact_id(GId)]
  : maxBid(M) &  price(P) [artifact_id(GId)] &
    M < P & nFailures(F)
  <- //.print("Max bid is less than new price. I am leaving the room");
     .print("Meu lance eh inferior ao novo preco. Saindo da sala.");
     removeBidder [artifact_id(GId)];
     ?name(G);
     -wantToBuy(G, _);
     +didNotBuy(G)
     stopFocus(GId);
     -+nFailures(F+1);
     .concat("prod_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     quitWorkspace(A).

+raisedPrice [artifact_id(GId)]
  : money(M) & price(P) [artifact_id(GId)] &
    M < P & nFailures(F)
  <- //.print("Money is less than new price. I am leaving the room");
     .print("Dinheiro inferior ao novo preco. Saindo da sala.");
     removeBidder [artifact_id(GId)];
     ?name(G);
     -wantToBuy(G, _);
     +didNotBuy(G)
     stopFocus(GId);
     -+nFailures(F+1);
     .concat("prod_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     quitWorkspace(A).

+raisedPrice [artifact_id(GId)].

+sold [artifact_id(GId)]
  : money(M) &
    price(P) &
    nSucesses(S)
  <- ?name(G);
    -+money(M - P);
     //.print("I bought ", G, " for ", P, "$.");
     //.print("Now I have ", M-P, "$.");
     .print("Comprei ", G, " por R$ ", P, " reais!");
     .print("Agora tenho R$ ", M-P, " reais.");
     
     .my_name(N);
      sold2(N) [artifact_id(GId)];
      +bought(G, P);
     -+nSucesses(S+1);
     -wantToBuy(G, _);
      stopFocus(GId);
     
     .concat("prod_", G, RoomName);
     ?joinedWsp(A,_,RoomName);
     .print("Saindo da sala.");
     
     quitWorkspace(A).
    

       

       