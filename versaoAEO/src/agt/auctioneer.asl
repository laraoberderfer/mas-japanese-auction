// Agent auctioneer in project

/* Initial beliefs and rules */

//!do_auction("a1","flight_ticket(paris,athens,date(15,12,2015))"). // initial goals
//!do_auction("a2","flight_ticket(athens,paris,18/12/2015)").
!do_auction(a1,"produtos(anahickman,1)").
!do_auction(a2,"produtos(mormaii,2)").
//!do_auction(a3,"produtos(dolce&gabana,3)").
//!do_auction(a4,"produtos(rayban,4)").
//!do_auction(a5,"produtos(prada,5)").
//!do_auction(a6,"produtos(dior, 6)").
//!do_auction(a7,"produtos(vogue, 7)").
//!do_auction(a8,"produtos(carrera, 8)").
//!do_auction(a9,"produtos(haru, 9)").
//!do_auction(a10,"produtos(gucci, 10)").

+!do_auction(Id,P)
   <- // creates a scheme to coordinate the auction
      .concat("sch_",Id,SchName);
      makeArtifact(SchName, "ora4mas.nopl.SchemeBoard",["src/org/auction_os.xml", doAuction],SchArtId);
      debug(inspector_gui(on))[artifact_id(SchArtId)];
      setArgumentValue(auction,"Id",Id)[artifact_id(SchArtId)];
      setArgumentValue(auction,"Service",P)[artifact_id(SchArtId)];
      .my_name(Me); setOwner(Me)[artifact_id(SchArtId)];  // I am the owner of this scheme!
      focus(SchArtId);
      addScheme(SchName);  // set the group as responsible for the scheme
      commitMission(mAuctioneer)[artifact_id(SchArtId)].

/* plans for organizational goals */

+!start[scheme(Sch)]                        // plan for the goal start defined in the scheme
   <- ?goalArgument(Sch,auction,"Id",Id);   // retrieve auction Id and service description S
      ?goalArgument(Sch,auction,"Service",S);
      .print("Iniciando leilao ",Sch," para ",S);
      makeArtifact(Id, "tools.AuctionArtifact", [], ArtId); // create the auction artifact
      Sch::focus(ArtId);  // place observable properties of ArtId into a name space     
      Sch::start(S).

+!decide[scheme(Sch)]
   <- Sch::stop.


+NS::winner(W) : W \== no_winner
   <- ?NS::task(S);
      ?NS::best_bid(V);
      .print("Vencedor ", S, " eh ",W," com ", V).

+oblUnfulfilled( obligation(Ag,_,done(Sch,bid,Ag),_ ) )[artifact_id(AId)]  // it is the case that a bid was not achieved
   <- .print("Comprador ",Ag," nao deu lance a tempo!");
       // TODO: implement an black list artifact
       admCommand("goalSatisfied(bid)")[artifact_id(AId)].

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
