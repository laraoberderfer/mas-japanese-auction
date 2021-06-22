{ include("produtos.asl") }

// Agent participant in project envCoordinationMAS

/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

+!focus(ArtId) // goal sent by the auctioneer
   <- lookupArtifact(ArtId,ToolId);
      focus(ToolId).

+task(D)[artifact_id(AId)] : running(true)[artifact_id(AId)]
   <- bid(math.random * 100 + 10)[artifact_id(AId)].

+winner(W) 
   : .my_name(W) 
   <- 
   .print("I Won!").

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
