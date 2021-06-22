// Agent sample_agent in project versionA
{ include("$moiseJar/asl/org-obedient.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Initial beliefs and rules */
nProdutos(10).
produtos("anahickman", 1).
produtos("mormaii", 2).
produtos("dolce&gabana", 3).
produtos("rayban", 4).
produtos("prada", 5).
produtos("dior", 6).
produtos("vogue", 7).
produtos("carrera", 8).
produtos("haru", 9).
produtos("gucci", 1).

/* Initial goals */

/* Plans */
+permission(Ag, MCond, committed(Ag, Mission, Scheme), Deadline) 
	: .my_name(Ag)
	<-  ?focusing(ArtId,Scheme,_,_,_,_)
	    commitMission(Mission)[artifact_id(ArtId)].
	    