{ include("produtos.asl") }
// Agent auctioneer in project 

/* Initial goals */


/* Plans */

+!start(Id,P)
   <- makeArtifact(Id, "tools.AuctionArtifact", [], ArtId);
      //.print("Auction artifact created for ",P);
      .print("Leilão para ", P, " iniciou!");
      Id::focus(ArtId);  // place observable properties of this auction in a particular name space
      Id::start(P);
      .broadcast(achieve,focus(Id));  // ask all others to focus on this new artifact
      .at("now + 5 seconds", {+!decide(Id)}).

+!decide(Id)
   <- Id::stop.
   
   +NameSpace::winner(W) : W \== no_winner
   <- ?NameSpace::task(S);
      ?NameSpace::best_bid(V);
      .print(W, " comprou ", S, " por R$ ", V, " reais!").
      //.print("Winner for ", S, " is ",W," with ", V).
   

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
