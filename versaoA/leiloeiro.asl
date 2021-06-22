{ include("produtos.asl") }

// Agent sample_agent in project versionA

/* Initial beliefs and rules */


/* Initial goals */

!start.


/* Plans */

+!start
    <- .wait(1000);
       !startAuctions.

+!startAuctions
    :  .findall(X, produtos(X, _), GoodsList) &
       GoodsList \== []
    <- .nth(0, GoodsList, G)
       ?produtos(G, P)
       .broadcast(tell, auctionStarted(G, P));
       .print("Leilão para ", G, " iniciou!");
       .wait(10);
       .print(G, ": valor agora eh de R$ ", P, " reais!");
       !checkParticipants(G).

+!startAuctions
    <- .print("------- Todos os produtos foram leiloados -------").

+!checkParticipants(G)
    :  .findall(A, joinedRoom(G)[source(A)], ParticipantsList) &
       .length(ParticipantsList) > 1
    <- !raisePrice(G, ParticipantsList).

+!checkParticipants(G)
    :  .findall(A, joinedRoom(G)[source(A)], ParticipantsList) &
       .length(ParticipantsList) == 1
    <- .nth(0, ParticipantsList, Winner);
       !annouceWinner(Winner, G).

+!checkParticipants(G)
    <- !annouceNoBidder(G).


+!raisePrice(G, ParticipantsList)
    : produtos(G, P)
    <- NewPrice = P + 1;
      -+produtos(G,NewPrice);
	  .print(G, ": valor agora eh de R$ ", NewPrice, " reais!");
      .send(ParticipantsList, tell, raisedPrice(G, NewPrice));
      .wait(10);
      !checkParticipants(G).

+!annouceWinner(Winner, G)
    : produtos(G, P)
    <- .print(Winner, " comprou ", G, " por R$ ", P, " reais!");
       .send(Winner, tell, bought(G, P));
       -produtos(G, P);
       !startAuctions.

+!annouceNoBidder(G)
    : produtos(G, P)
    <- .print("Sem lances para o produto ", G, " por R$ ", P, " reais!");
       -produtos(G, P);
       !startAuctions.

+leavedRoom(G)[source(A)]
    <- -joinedRoom(G)[source(A)];
       -leavedRoom(G)[source(A)];
       .print(A, " abandonou a sala do produto: ", G).

