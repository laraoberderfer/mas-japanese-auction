{ include("produtos.asl") }

// Agent in project versionA

/* Initial beliefs and rules */
nSucesses(0).
nFailures(0).
money(0).
counter(0).

/* Initial goals */

!getMoney.
!chooseProdQuantity.

/* Plans */

+!getMoney
  : .random(R)
  <- -+money(math.round(R*1000)+100);
     .print("Possui R$ ", math.round(R*1000)+100, " reais!").

+!chooseProdQuantity
  : .random(R) &
    nProdutos(NG) &
    N = math.ceil(NG*R)
  <- +prodQuantity(N);
     !chooseProd.

+!chooseProd
  : prodQuantity(N) &
    counter(C) &
    C < N 
  <- .findall(X, produtos(X, _), GoodsList);
     .shuffle(GoodsList, GoodsListShuffled);
     .nth(0, GoodsListShuffled, G);
     +wantToBuy(G);
     -produtos(G, _);
     -+counter(C+1);
     !chooseProd.

+!chooseProd 
  <- .findall(X, wantToBuy(X), L);
     .print("Tenho intensao de comprar: ", L);
     .abolish(produtos(_,_));
     -counter(_).

@atomic
+auctionStarted(G, InitialPrice)[source(A)]
  : wantToBuy(G) &
    money(M) & 
    InitialPrice < M
  <- !getMaxBid(G, InitialPrice);
     .send(A, tell, joinedRoom(G));
     .print("Entrou na sala para dar lance no produto: ", G);
     +room(G);
     -auctionStarted.

+auctionStarted(G, InitialPrice)[source(A)]
  : wantToBuy(G)
  <- .print("Nao tem dinheiro suficiente para dar lance no produto: ", G, ".");
     -wantToBuy(G);
     +didNotBuy(G);
     -+nFailures(F+1);
     -auctionStarted.

+auctionStarted(G, InitialPrice)[source(A)]
  <- -auctionStarted.

+raisedPrice(G, NewPrice)[source(A)]
  : maxBid(G, M) &
    M < NewPrice &
    nFailures(F)
  <- .print("O lance max eh inferior ao novo preco. Saindo da sala do produto: ", G);
     .send(A, tell, leavedRoom(G));
     -+nFailures(F+1);
     -room(G);
     -wantToBuy(G);
     -raisedPrice(G, NewPrice)[source(A)];
     +didNotBuy(G).

+raisedPrice(G, NewPrice)[source(A)]
  : money(M) &
    M < NewPrice &
    nFailures(F)
  <- .print("Dinheiro inferior ao novo preco. Saindo da sala do produto: ", G);
     .send(A, tell, leavedRoom(G));
     -+nFailures(F+1);
     -room(G);
     -wantToBuy(G);
     -raisedPrice(G, NewPrice)[source(A)];
     +didNotBuy(G).

+raisedPrice(G, NewPrice)[source(A)]
  <- -raisedPrice(G, NewPrice)[source(A)].


+bought(G, Price)
  : money(M) &
    nSucesses(S)
  <- -+money(M - Price);
     .print("Comprou ", G, " por R$ ", Price, " reais!");
     .print("Agora tenho R$ ", M-Price, " reais.");
     -+nSucesses(S+1);
     -wantToBuy(G);
     -room(G).    

       