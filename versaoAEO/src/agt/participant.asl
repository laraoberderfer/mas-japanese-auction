+!bid[scheme(Sch)]
   <- ?goalArgument(Sch,auction,"Id",Id);    // retrieve auction id and focus on the artifact
      lookupArtifact(Id,AId);
      focus(AId);
      if (math.random  < 0.5) {              // bid in 50% of the cases
        .wait(math.random * 2000 + 500);     // to simulate some "decision" reasoning
        bid(math.random * 100 + 10)[artifact_id(AId)];
      } else {
        .fail;                               // fail otherwise
      }.

-!bid[error(ia_failed)] <- .print("Nao dei lance!").
-!bid[error_msg(M)]     <- .print("Error lance: ",M).

+best_bid(Value)[artifact_id(AId)]:running(true)[artifact_id(AId)]
   <- 
   	  .wait(1000)
   	  !bidNewOffer(Value,AId).
   	  
+!bidNewOffer(Value,ArtId)[source(self)]:running(true)[artifact_id(ArtId)]
   <-
	?task(AuctionItem)[artifact_id(AId)]; 
	.println("Melhor oferta para ",AuctionItem," eh ",Value, ", ofertando novamente.");
	?running(AuctionRunningState)[artifact_id(AId)];
	if (AuctionRunningState == true) {
		bid(Value * 0.9)[artifact_id(AId)]	
	}.

-!bidNewOffer(Value,ArtId)[source(self)]:true
	<- 
	if(.fail_goal(bidNewOffer(Value,ArtId)[source(self)])) {
		?task(AuctionItem)[artifact_id(ArtId)] //Retrieve the auction task belief about current artifact observable property.
		?running(AuctionState)[artifact_id(ArtId)] // The same to running observable property. 
		println(
			"Falha para o leilao ",AuctionItem,
			" no estado ",AuctionState
		)
	}.  	  
   	  
+winner(W) : .my_name(W) <- .print("Ganhei o lance!").
/*+!bid[scheme(Sch)]
   <- ?goalArgument(Sch,auction,"Id",Id); // retrieve auction id and focus on the artifact
      lookupArtifact(Id,AId);
      focus(AId);
      .wait(math.random * 2000 + 500); 
       bid(math.random * 100 + 10);
       goalAchieved(decide)[artifact_name(Sch)]; //new
       .
        
+best_bid(Value)[artifact_id(AId)]:running(true)[artifact_id(AId)]
   <- 
   	  .wait(1000)
   	  !bidNewOffer(Value,AId).

+!bidNewOffer(Value,ArtId)[source(self)]:running(true)[artifact_id(ArtId)]
   <-
	?task(AuctionItem)[artifact_id(AId)]; 
	.println("Best current offer for ",AuctionItem," is ",Value, ", offering new one");
	?running(AuctionRunningState)[artifact_id(AId)];
	if (AuctionRunningState == true) {
		bid(Value * 0.9)[artifact_id(AId)]	
	}.

//Plan to handle bidNewOffer goal fails when an agent bids at closed auction
-!bidNewOffer(Value,ArtId)[source(self)]:true
	<- 
	if(.fail_goal(bidNewOffer(Value,ArtId)[source(self)])) {
		?task(AuctionItem)[artifact_id(ArtId)] //Retrieve the auction task belief about current artifact observable property.
		?running(AuctionState)[artifact_id(ArtId)] // The same to running observable property. 
		println(
			"Fail to offer at Auction ",AuctionItem,
			" when auction state running is ",AuctionState
		)
	}.

+running(Value)[artifact_id(AId)] : Value == false & .desire(bidNewOffer(Value,ArtId)[artifact_id(AId)])
   <- 
	?task(AuctionItem)[artifact_id(AId)];
	.println("auction ",AuctionItem, " finished, cancel my offer intention");
	.drop_intention(bid(ServDesc)[artifact_id(AId)]).

+running(Value)[artifact_id(AId)] : Value == false & .desire(bid(Value)[artifact_id(AId)])
   <- 
	?task(AuctionItem)[artifact_id(AId)];
	.println("auction ",AuctionItem, " finished, cancel my offer intention");
	.drop_intention(bid(ServDesc)[artifact_id(AId)]).
	
+winner(W) : .my_name(W) <- .print("I Won!").
 */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
