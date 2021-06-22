{ include("comprador.asl") }

/* Plans */
+!getMaxBid(G, InitialPrice)
  <- +maxBid(G, InitialPrice).
