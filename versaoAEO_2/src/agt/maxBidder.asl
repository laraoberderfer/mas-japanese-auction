{ include("comprador.asl") }

/* Plans */
+!getMaxBid(G, InitialPrice)
  : money(M)
  <- -+maxBid(M).

     
    

       